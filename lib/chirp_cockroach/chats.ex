defmodule ChirpCockroach.Chats do
  import Ecto.Query

  alias ChirpCockroach.Repo
  alias ChirpCockroach.Chats
  alias ChirpCockroach.Accounts

  @spec list_chat_rooms() :: list(Chats.Room.t())
  def list_chat_rooms do
    Chats.Room
    |> Repo.all()
    |> Repo.preload([:user, :users])
  end

  @spec get_room_messages(Chats.Room.t()) :: list(Chats.Message.t())
  def get_room_messages(%{id: room_id} = _room) do
    Chats.Message
    |> where(room_id: ^room_id)
    |> Repo.all()
    |> Repo.preload(:user)
  end

  @spec list_user_rooms(Accounts.User.t()) :: list(Chats.Room.t())
  def list_user_rooms(%{id: user_id}) do
    room_ids = Chats.Participant |> where(user_id: ^user_id) |> select([:room_id])

    Chats.Room
    |> where([room], room.id in subquery(room_ids))
    |> Repo.all()
    |> Repo.preload([:users])
  end

  def get_room!(id) do
    Chats.Room
    |> Repo.get!(id)
    |> Repo.preload([:user, :users])
  end

  @doc """
  Creates a room.

  ## Examples

      iex> create_room(%{field: value})
      {:ok, %Room{}}

      iex> create_room(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_room(user, attrs \\ %{}) do
    %Chats.Room{user_id: user.id}
    |> Chats.Room.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, room} ->
        Chats.EventHandler.handle(%Chats.Events.RoomCreated{room: room})

        {:ok, room}

      error ->
        error
    end
  end

  @doc """
  User joins a room.
  """
  @spec join_room(Accounts.User.t(), Chats.Room.t()) :: {:ok, Chats.Participant.t()} | {:error, :already_joined | Ecto.Changeset.t()}
  def join_room(user, room) do
    with nil <- get_participant(user, room),
         {:ok, participant} <- create_participant(user, room) do
      Chats.EventHandler.handle(%Chats.Events.RoomJoinedByUser{room: room, user: user})

      {:ok, participant}
         else
          %Chats.Participant{} -> {:error, :already_joined}
          {:error, _} = error -> error
    end
  end

  @doc """
  User leaves a room.
  """
  @spec leave_room(Accounts.User.t(), Chats.Room.t()) :: :ok | {:error, :participant_not_found | Ecto.Changeset.t()}
  def leave_room(user, room) do
    with %{} = participant <- get_participant(user, room),
         {:ok, _} <- Repo.delete(participant) do
      Chats.EventHandler.handle(%Chats.Events.RoomLeftByUser{room: room, user: user})
      :ok
    else
      nil -> {:error, :participant_not_found}
      {:error, _} = error -> error
    end
  end

  defp get_participant(user, room) do
    Repo.get_by(Chats.Participant, user_id: user.id, room_id: room.id)
  end

  defp create_participant(user, room) do
    %Chats.Participant{user_id: user.id, room_id: room.id}
    |> Repo.insert()
  end


  @spec send_to_room(Accounts.User.t(), Chats.Room.t(), map()) :: {:ok, Chats.Message.t()}
  def send_to_room(user, room, %{"text" => "/dance" <> _any}) do
    create_event_message(user, room, %{text: "is dancing!"})
  end

  def send_to_room(user, room, %{"text" => "/sing" <> _any}) do
    create_event_message(user, room, %{text: "is singing"})
  end

  def send_to_room(user, room, %{"text" => "/leave" <> _any}) do
    leave_room(user, room)
  end

  def send_to_room(user, room, attrs), do: create_text_message(user, room, attrs)


  defp create_text_message(user, room, attrs \\ %{}) do
    %Chats.Message{user_id: user.id, room_id: room.id, kind: :text}
    |> Chats.Message.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, message} = result ->
        Chats.EventHandler.handle(%Chats.Events.NewMessageInRoom{room: room, message: message})

        result

      error ->
        error
    end
  end

  def send_voice_to_room(user, room, %{path: path}) do
    %Chats.Message{user_id: user.id, room_id: room.id, kind: :voice, file_path: path}
    |> Repo.insert()
    |> case do
      {:ok, message} = result ->
        Chats.EventHandler.handle(%Chats.Events.NewMessageInRoom{room: room, message: message})
        transcribe_voice_message!(message)

        result

      error ->
        error
    end
  end

  def create_event_message(user, room, attrs \\ %{}) do
    %Chats.Message{user_id: user.id, room_id: room.id, kind: :event}
    |> Chats.Message.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, message} = result ->
        Chats.EventHandler.handle(%Chats.Events.NewMessageInRoom{room: room, message: message})

        result

      error ->
        error
    end
  end

  def transcribe_voice_message!(message) do
    Task.async(fn ->
      message.file_path
      |> ChirpCockroach.Files.file_source()
      |> ChirpCockroach.Audio.transcribe()
      |> case do
        {:ok, %{transcription: transcription}} ->
          message =
            message
            |> Chats.Message.changeset(%{text: "said \"#{transcription}\""})
            |> Repo.update!()
            |> Repo.preload(:room)

          Chats.EventHandler.handle(%Chats.Events.NewMessageInRoom{
            room: message.room,
            message: message
          })
      end
    end)
  end

  def create_transcription_message(user, room, attrs \\ %{}) do
    %Chats.Message{user_id: user.id, room_id: room.id, kind: :transcription}
    |> Chats.Message.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, message} = result ->
        Chats.EventHandler.handle(%Chats.Events.NewMessageInRoom{room: room, message: message})

        result

      error ->
        error
    end
  end

  @doc """
  Updates a room.

  ## Examples

      iex> update_room(room, %{field: new_value})
      {:ok, %Room{}}

      iex> update_room(room, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_room(%Chats.Room{} = room, attrs) do
    room
    |> Chats.Room.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a room.

  ## Examples

      iex> delete_room(room)
      {:ok, %Room{}}

      iex> delete_room(room)
      {:error, %Ecto.Changeset{}}

  """
  def delete_room(%Chats.Room{} = room) do
    Repo.delete(room)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking room changes.

  ## Examples

      iex> change_room(room)
      %Ecto.Changeset{data: %Room{}}

  """
  def change_room(%Chats.Room{} = room, attrs \\ %{}) do
    Chats.Room.changeset(room, attrs)
  end

  def subscribe() do
    Phoenix.PubSub.subscribe(ChirpCockroach.PubSub, "chats")
  end

  def broadcast(event) do
    Phoenix.PubSub.broadcast(ChirpCockroach.PubSub, "chats", event)
  end

  def room_subscribe(room) do
    Phoenix.PubSub.subscribe(ChirpCockroach.PubSub, "chats:room:#{room.id}")
  end

  def room_broadcast(%{id: room_id}, event) do
    Phoenix.PubSub.broadcast(ChirpCockroach.PubSub, "chats:room:#{room_id}", event)
  end
end
