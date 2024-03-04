defmodule ChirpCockroachWeb.Video.MicrophoneComponent do
  use ChirpCockroachWeb, :live_component



  @impl true
  def render(assigns) do
    ~H"""
    <button id="microphoneButton" phx-hook="microphoneHook">
      Microphone
    </button>
    """
  end
end
