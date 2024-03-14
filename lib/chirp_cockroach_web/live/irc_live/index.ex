defmodule ChirpCockroachWeb.IrcLive.Index do
  use ChirpCockroachWeb, :live_view
  import ChirpCockroachWeb.MultimediaComponents
  import ChirpCockroachWeb.IrcLive.IrcComponents

  alias ChirpCockroach.Chats

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Chats.subscribe()
    end

    socket =
      socket
      |> stream_configure(:rooms, dom_id: &"joined-room-#{&1.id}")
      |> stream_configure(:messages, dom_id: &"room-#{&1.room_id}-message-#{&1.id}")
      |> stream_configure(:video_streams, dom_id: &"video-stream-#{&1.peer_id}")

    {:ok,
     socket
     |> stream(:rooms, Chats.list_user_rooms(socket.assigns.current_user), reset: true)
     |> assign(:all_rooms, [])
     |> reset_active_room()}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "IRC")
    |> reset_active_room()
    |> assign(:all_rooms, Chats.list_chat_rooms())
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Room")
    |> reset_active_room()
    |> assign(:room, %Chats.Room{})
  end

  defp apply_action(socket, :show, %{"id" => room_id}) do
    socket.assigns.current_user
    |> Chats.get_joined_room(room_id)
    |> case do
      %Chats.Room{} = room ->
        set_active_room(socket, room)

      nil ->
        push_patch(socket, to: ~p"/irc")
    end
  end

  defp set_active_room(socket, room) do
    Chats.room_subscribe(room)

    %{peers: video_streams} =  ChirpCockroach.Video.Call.get_call(room)

    socket
    |> assign(:page_title, room.name)
    |> assign(:room, room)
    |> assign(:peer_id, nil)
    |> stream(:video_streams, video_streams, reset: true)
    |> stream(:messages, Enum.reverse(Chats.get_room_messages(room)), reset: true)
    |> assign(:message_changeset, Chats.Message.changeset(%Chats.Message{}, %{}))

  end

  defp reset_active_room(socket) do
    socket
    |> assign(:room, nil)
    |> assign(:peer_id, nil)
    |> stream(:messages, [], reset: true)
    |> stream(:video_streams, [], reset: true)
    |> assign(:message_changeset, Chats.Message.changeset(%Chats.Message{}, %{}))
  end

  @impl true
  @room_events [:room_created, :room_updated, :room_joined]

  def handle_info({event_type, room}, socket) when event_type in @room_events do
    socket
    |> stream_insert(:rooms, room)
    |> noreply()
  end

  def handle_info({:room_left, room}, socket) do
    socket
    |> stream_delete(:room, room)
    |> push_patch(to: ~p"/irc")
    |> noreply()
  end

  def handle_info({:new_message_in_room, message}, socket) do
    if active_room?(socket, message) do
      {:noreply, socket |> stream_insert(:messages, message, at: 0)}
    else
      {:noreply, socket}
    end
  end

  def handle_info({:video_stream_added, peer}, socket) do
    if active_room?(socket, peer) do
      {:noreply, socket |> stream_insert(:video_streams, peer)}
    else
      {:noreply, socket}
    end
  end

  def handle_info({:video_stream_removed, peer}, socket) do
    if active_room?(socket, peer) do
      {:noreply, socket |> stream_delete(:video_streams, peer)}
    else
      {:noreply, socket}
    end
  end

  def handle_info(_socket, event) do
    raise event
  end

  defp active_room?(%{assigns: %{room: %{id: room_id}}}, %{room_id: room_id}) do
    true
  end

  defp active_room?(_socket, _event), do: false

  @impl true
  def handle_event("join-room", %{"room_id" => room_id}, socket) do
    room = Chats.get_room!(room_id)

    {:ok, _} = Chats.join_room(socket.assigns.current_user, room)

    socket |> stream_insert(:rooms, room, at: 0) |> noreply()
  end

  def handle_event("leave-room", %{"room_id" => room_id}, socket) do
    room = Chats.get_room!(room_id)

    :ok = Chats.leave_room(socket.assigns.current_user, room)

    socket |> stream_delete(:rooms, room) |> push_patch(to: ~p"/irc") |> noreply()
  end

  def handle_event("set-peer-id", %{"peer_id" => peer_id}, socket) do
    socket
    |> assign(:peer_id, peer_id)
    |> noreply()
  end

  def handle_event("start-stream", _, socket) do
    ChirpCockroach.Video.start_stream(socket.assigns.current_user, socket.assigns.room, socket.assigns.peer_id)
    {:noreply, socket}
  end

  defp noreply(socket) do
    {:noreply, socket}
  end
end
