defmodule ChirpCockroach.Chats.EventHandler do
  alias ChirpCockroach.Chats
  alias ChirpCockroach.Repo

  def handle(%Chats.Events.RoomCreated{room: room}) do
    Chats.broadcast({:room_created, Repo.preload(room, :users)})

    :ok
  end

  def handle(%Chats.Events.RoomJoinedByUser{room: room, user: user}) do
    room = Repo.preload(room, :users, force: true)

    Chats.create_event_message(user, room, %{text: "joined a room"})
    :ok
  end

  def handle(%Chats.Events.RoomLeftByUser{room: room, user: user}) do
    room = Repo.preload(room, :users, force: true)

    Chats.create_event_message(user, room, %{text: "left a room"})
    Chats.room_broadcast(room, {:room_updated, room})

    :ok
  end

  def handle(%Chats.Events.NewMessageInRoom{message: message}) do
    Chats.room_broadcast(message, {:message_created, Repo.preload(message, :user)})

    :ok
  end

  def handle(%ChirpCockroach.Video.Events.VideoStreamAdded{peer: peer}) do
    Chats.room_broadcast(peer, {:video_stream_added, peer})

    :ok
  end

  def handle(%ChirpCockroach.Video.Events.VideoStreamRemoved{peer: peer}) do
    Chats.room_broadcast(peer, {:video_stream_removed, peer})

    :ok
  end

  def handle(_), do: :ok
end
