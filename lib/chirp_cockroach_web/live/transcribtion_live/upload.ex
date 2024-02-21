defmodule ChirpCockroachWeb.TranscribeLive.Show do
  use ChirpCockroachWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    id = Ecto.UUID.generate()
    Phoenix.PubSub.subscribe(ChirpCockroach.PubSub, "transcription")

    {:ok,
     socket
     |> assign(:uploaded_files, [])
     |> assign(:transcription_id, id)
     |> assign(:transcription, [])
     |> allow_upload(:audio, accept: ~w(.mp3), max_entries: 10, max_file_size: 120_000_000)}
  end

  def handle_event("transcribe", _, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("save", _, socket) do
    Phoenix.PubSub.subscribe(ChirpCockroach.PubSub, "transcription")

    uploaded_files =
      consume_uploaded_entries(socket, :audio, fn %{path: path}, _entry ->
        ChirpCockroach.Audio.whisper(path, fn timestamp, %{chunks: [%{text: text}]} ->
          Phoenix.PubSub.broadcast(ChirpCockroach.PubSub, "transcription", %{
            timestamp: timestamp,
            text: text
          })
        end)

        {:ok, path}
      end)

    {:noreply, update(socket, :uploaded_files, &(&1 ++ uploaded_files))}
  end

  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :audio, ref)}
  end

  @impl true

  def handle_info(%{timestamp: _timestamp, text: _text} = transcription, socket) do
    {:noreply, assign(socket, :transcription, [transcription | socket.assigns.transcription])}
  end

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
end
