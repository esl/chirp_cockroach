defmodule ChirpCockroachWeb.Video.CameraComponent do
  use ChirpCockroachWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <button id="cameraButton" phx-hook="cameraHook">
      Video
    </button>
    """
  end

  def handle_event(_, %{}, socket) do
    {:noreply, socket}
  end
end
