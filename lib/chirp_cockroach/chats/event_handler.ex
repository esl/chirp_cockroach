defmodule ChirpCockroach.Chats.EventHandler do
  alias ChirpCockroach.Chats
  alias ChirpCockroach.Repo

  def handle(%Chats.Events.RoomCreated{room: room} = event) do
    Chats.broadcast({:room_created, Repo.preload(room, :users)})

    :ok
  end

  def handle(%Chats.Events.RoomJoinedByUser{room: room, user: user} = event) do
    room = Repo.preload(room, :users)

    Chats.create_event_message(user, room, %{text: "joined a room"})

    :ok
  end

  def handle(%Chats.Events.RoomLeftByUser{room: room, user: user} = event) do
    room = Repo.preload(room, :users)

    Chats.create_event_message(user, room, %{text: "left a room"})

    Enum.each(room.users, fn user ->
      Chats.user_broadcast(user, {:room_updated, room})
    end)

    :ok
  end

  def handle(%Chats.Events.NewMessageInRoom{room: room, message: message}) do
    room = Repo.preload(room, :users)
    message = Repo.preload(message, :user)

    Chats.room_broadcast(room, {:new_message_in_room, room, message})

    Enum.each(room.users, fn user ->
      Chats.user_broadcast(user, {:new_message_in_room, room, message})
    end)

    :ok
  end

  def handle(_), do: :ok
end
