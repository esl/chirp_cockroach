defmodule ChirpCockroachWeb.TranscribeLive.Microphone do
  use ChirpCockroachWeb, :live_view

  alias ChirpCockroach.Audio

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(transcription: nil)
     |> allow_upload(:audio, accept: :any, progress: &handle_progress/3, auto_upload: true)}
  end

  defp handle_progress(:audio, entry, socket) when entry.done? do
    binary =
      consume_uploaded_entry(socket, entry, fn %{path: path} ->
        {:ok, File.read!(path)}
      end)

    audio = Nx.from_binary(binary, :f32)

    socket =
      socket
      |> assign(:transcription, nil)
      |> assign_async(:transcription, fn ->
        ChirpCockroach.Audio.transcribe(audio)
      end)

    {:noreply, socket}
  end

  defp handle_progress(_name, _entry, socket), do: {:noreply, socket}

  @impl true
  def handle_event("noop", %{}, socket) do
    # We need phx-change and phx-submit on the form for live uploads,
    # but we make predictions immediately using :progress, so we just
    # ignore this event
    {:noreply, socket}
  end
end
