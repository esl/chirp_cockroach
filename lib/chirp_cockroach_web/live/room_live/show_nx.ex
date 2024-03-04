defmodule ChirpCockroachWeb.RoomLive.ShowNx do
  use ChirpCockroachWeb, :live_view

  alias ChirpCockroach.Video

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    room = Video.get_room!(id)
    participants = Video.get_room_participants!(id)
    if connected?(socket), do: Video.subscribe(room)

    {:noreply,
     socket
     |> assign(:peer_id, nil)
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:room, room)
     |> stream(:participants, participants)}
  end

  @impl true
  def handle_event("join-room", _, socket) do
    if socket.assigns.peer_id do
      Video.join(socket.assigns.room, socket.assigns.peer_id)
      {:noreply, socket}
    else
      raise socket.assigns
    end
  end

  def handle_event("set-peer_id", %{"peer_id" => peer_id}, socket) do
    {:noreply,
     socket
     |> assign(:peer_id, peer_id)
     |> assign(:page_title, page_title(socket.assigns.live_action))}
  end

  @impl true
  def handle_info({:participant_joined, participant}, socket) do
    {:noreply, stream_insert(socket, :participants, participant)}
  end

  def handle_info({:participant_left, participant}, socket) do
    {:noreply, stream_delete(socket, :participants, participant)}
  end

  defp page_title(:show), do: "Show Room"
  defp page_title(:edit), do: "Edit Room"
  defp page_title(:join), do: "Join Room"
end
