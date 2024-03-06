defmodule ChirpCockroach.Chats do
  import Ecto.Query

  alias ChirpCockroach.Repo
  alias ChirpCockroach.Chats

  def list_chat_rooms do
    Chats.Room
    |> Repo.all()
    |> Repo.preload([:user, :users])
  end

  def get_room_messages(%{id: room_id} = room) do
    Chats.Message
    |> where(room_id: ^room_id)
    |> Repo.all()
    |> Repo.preload(:user)
  end

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

  def join_room(user, room) do
    %Chats.Participant{user_id: user.id, room_id: room.id}
    |> Repo.insert()
    |> case do
      {:ok, participant} = result ->
        Chats.create_event_message(user, room, %{text: "joined a room"})

        Chats.EventHandler.handle(%Chats.Events.RoomJoinedByUser{room: room, user: user})

        result

      error ->
        error
    end
  end

  def leave_room(user, room) do
    Chats.Participant
    |> Repo.get_by!(user_id: user.id, room_id: room.id)
    |> Repo.delete()
    |> case do
      {:ok, _} ->
        Chats.create_event_message(user, room, %{text: "left a room"})

        Chats.EventHandler.handle(%Chats.Events.RoomLeftByUser{room: room, user: user})

        :ok

      error ->
        error
    end
  end

  def send_to_room(user, room, %{"text" => "/dance" <> _any}) do
    create_event_message(user, room, %{text: "is dancing!"})
  end

  def send_to_room(user, room, %{"text" => "/leave" <> _any}) do
    leave_room(user, room)
  end

  def send_to_room(user, room, attrs), do: send_text_message(user, room, attrs)

  def send_text_message(user, room, attrs \\ %{}) do
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

  def user_subscribe(user) do
    Phoenix.PubSub.subscribe(ChirpCockroach.PubSub, "chats:users:#{user.id}")
  end

  def user_broadcast(%{id: user_id}, event) do
    Phoenix.PubSub.broadcast(ChirpCockroach.PubSub, "chats:users:#{user_id}", event)
  end
end
