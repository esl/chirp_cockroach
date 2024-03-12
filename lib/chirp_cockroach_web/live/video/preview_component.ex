defmodule ChirpCockroachWeb.Video.PreviewComponent do
  use ChirpCockroachWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <video id="preview-video" phx-hook="previewHook" style="width: 320px; height: 240px; border: 1px solid orange;">
    </video>
    """
  end
end
