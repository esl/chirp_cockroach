defmodule ChirpCockroachWeb.Video.MicrophoneComponent do
  use ChirpCockroachWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <button id="microphoneButton" phx-hook="microphone" data-upload={@upload} data-endianness={System.endianness()}>
      Microphone
    </button>
    """
  end

  def handle_event(_, %{}, socket) do
    {:noreply, socket}
  end
end
