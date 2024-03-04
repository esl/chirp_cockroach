defmodule ChirpCockroachWeb.TranscribeLive.Upload do
  use ChirpCockroachWeb, :live_view

  alias ChirpCockroach.Audio
  alias ChirpCockroach.Files

  @impl true
  def mount(_params, _session, socket) do
    id = Ecto.UUID.generate()
    Phoenix.PubSub.subscribe(ChirpCockroach.PubSub, "transcription")

    {:ok,
     socket
     |> assign(:uploaded_files, [])
     |> assign(:transcription_id, id)
     |> assign(:transcription, [])
     |> allow_upload(:audio,
       accept: ~w(.mp3),
       max_entries: 10,
       max_file_size: 120_000_000
     )}
  end

  def handle_event("transcribe", _, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("save", _, socket) do
    pid = self()

    files = consume_uploaded_entries(socket, :audio, &process_tmp_audio_file/2)
    IO.inspect(files)

    Task.async(fn ->
      Enum.each(files, fn %{path: path, filename: filename} ->
        IO.inspect(%{path: path})

        ChirpCockroach.Audio.whisper(path, fn timestamp, %{chunks: [%{text: text}]} ->
          IO.inspect(text)

          send(
            pid,
            {:transcription,
             %{
               label: "#{filename}: (#{timestamp})",
               text: text
             }}
          )
        end)

        Files.delete_tmp_file(filename)
      end)
    end)

    {:noreply, socket}
  end

  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :audio, ref)}
  end

  @impl true
  def handle_info({:transcription, entry}, socket) do
    {:noreply, assign(socket, :transcription, [entry | socket.assigns.transcription])}
  end

  defp process_tmp_audio_file(%{path: path}, _entry) do
    upload_id = Ecto.UUID.generate()
    filename = "#{upload_id}.mp3"
    {:ok, path} = Files.persist_tmp_file(path, "#{upload_id}.mp3")
    {:ok, %{path: path, filename: filename}}
  end

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
end
