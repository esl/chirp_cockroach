defmodule ChirpCockroachWeb.IrcLive.Index do
  use ChirpCockroachWeb, :live_view

  import ChirpCockroachWeb.IrcLive.IrcComponents

  alias ChirpCockroach.Chats

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Chats.subscribe()
      Chats.user_subscribe(socket.assigns.current_user)
    end

    socket =
      socket
      |> stream_configure(:rooms, dom_id: &"room-#{&1.id}")
      |> stream_configure(:messages, dom_id: &"room-#{&1.room_id}-message-#{&1.id}", limit: 10)

    {:ok,
     socket
     |> stream(:rooms, Chats.list_user_rooms(socket.assigns.current_user))
     |> assign(:all_rooms, [])
     |> stream(:messages, [], limit: 10)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "IRC")
    |> assign(:room, nil)
    |> assign(:all_rooms, Chats.list_chat_rooms())
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Room")
    |> assign(:room, %Chats.Room{})
  end

  defp apply_action(socket, :show, %{"id" => id}) do
    room = Chats.get_room!(id)

    Chats.room_subscribe(room)

    if Enum.any?(room.users, &(&1.id == socket.assigns.current_user.id)) do
      socket
      |> assign(:page_title, room.name)
      |> assign(:room, room)
      |> stream(:messages, Chats.get_room_messages(room), reset: true, limit: 10)
      |> assign(:message_changeset, Chats.Message.changeset(%Chats.Message{}, %{}))
    else
      socket
      |> push_patch(to: ~p"/irc")
    end
  end

  @impl true
  def handle_info({:room_created, room}, socket) do
    # Ignore for now
    {:noreply, socket}
  end

  def handle_info({:room_updated, room}, socket) do
    {:noreply, stream_insert(socket, :rooms, room)}
  end

  def handle_info({:room_joined, room}, socket) do
    {:noreply, stream_insert(socket, :rooms, room)}
  end

  def handle_info({:room_left, room}, socket) do
    {:noreply, stream_delete(socket, :room, room) |> push_patch(to: ~p"/irc")}
  end

  def handle_info(
        {:new_message_in_room, %{id: room_id} = room, message},
        %{assigns: %{room: %{id: room_id}}} = socket
      ) do
    {:noreply, socket |> stream_insert(:messages, message, limit: 10)}
  end

  def handle_info({:new_message_in_room, room, message}, socket) do
    {:noreply, socket}
  end

  def handle_info(undefined_event, socket) do
    raise undefined_event
  end

  @impl true
  def handle_event("join-room", %{"room_id" => room_id}, socket) do
    room = Chats.get_room!(room_id)

    {:ok, _} = Chats.join_room(socket.assigns.current_user, room)

    {:noreply, socket |> stream_insert(:rooms, room)}
  end

  def handle_event("leave-room", %{"room_id" => room_id}, socket) do
    room = Chats.get_room!(room_id)

    {:ok, _} = Chats.leave_room(socket.assigns.current_user, room)

    {:noreply, socket |> stream_delete(:rooms, room) |> push_patch(to: ~p"/irc")}
  end
end
