defmodule ChirpCockroachWeb.IrcLive.RoomsList do
  use ChirpCockroachWeb, :live_component

  alias ChirpCockroach.Chats

  @impl true
  def mount(socket) do
    if IO.inspect(connected?(socket)), do: Chats.subscribe()

    {:ok, stream(socket, :rooms, Chats.list_chat_rooms())}
  end

  def handle_info(x, y) do
    IO.inspect(x)
    {:noreply, y}
  end

  def handle_info({:room_created, room}, socket) do
    {:noreply, stream_insert(socket, :rooms, room)}
  end
end
