defmodule ChirpCockroachWeb.TranscribeLive.Microphone do
  use ChirpCockroachWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
