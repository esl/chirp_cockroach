defmodule ChirpCockroachWeb.RoomLive.Index do
  use ChirpCockroachWeb, :live_view

  alias ChirpCockroach.Video
  alias ChirpCockroach.Video.Room

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :video_rooms, list_video_rooms())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Room")
    |> assign(:room, Video.get_room!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Room")
    |> assign(:room, %Room{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Video rooms")
    |> assign(:room, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    room = Video.get_room!(id)
    {:ok, _} = Video.delete_room(room)

    {:noreply, assign(socket, :video_rooms, list_video_rooms())}
  end

  defp list_video_rooms do
    Video.list_video_rooms()
  end
end
