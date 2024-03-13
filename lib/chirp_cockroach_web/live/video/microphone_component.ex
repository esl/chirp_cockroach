defmodule ChirpCockroachWeb.Video.MicrophoneComponent do
  use ChirpCockroachWeb, :live_component

  @impl true
  def render(assigns) do
    content = Map.get(assigns, :content, "Microphone")
    assigns = Map.put(assigns, :content, content)
    ~H"""
    <button id="microphoneButton" phx-hook="microphone" data-upload={@upload} data-endianness={System.endianness()}>
      <%= @content %>
    </button>
    """
  end
end
