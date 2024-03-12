defmodule ChirpCockroachWeb.Video.TranscriptionComponent do
  use ChirpCockroachWeb, :live_component

  @impl true
  def mount(socket) do
    upload_id = Ecto.UUID.generate()

    {:ok,
     socket
     |> assign(:transcription, nil)
     |> assign(:upload_id, upload_id)
     |> allow_upload(upload_id, accept: :any, progress: &handle_progress/3, auto_upload: true)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div id={"transcription-#{@upload_id}"} phx-hook="transcriptionHook" data-endianness={System.endianness()} data-stream_id={@stream_id} data-upload_id={@upload_id}>
      <form phx-change="noop" phx-submit="noop" class="hidden" hidden phx-target={@myself}>
        <.live_file_input id={"upload-#{@upload_id}"} upload={@uploads[@upload_id]} phx-target={@myself}/>
      </form>

      <div class="mt-6 flex space-x-1.5 items-center text-gray-600 text-lg">
        <div>Transcription:</div>
        <.async_result :let={transcription} assign={@transcription} :if={@transcription}>
          <:loading>
            Loading
          </:loading>
          <:failed :let={_reason}>
            <span>Oops, something went wrong!</span>
          </:failed>
          <span class="text-gray-900 font-medium"><%= transcription %></span>
        </.async_result>
      </div>
    </div>
    """
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
        IO.inspect(:transcribe)
        ChirpCockroach.Audio.transcribe(audio) |> IO.inspect()
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

  def handle_info(
        %Phoenix.Socket.Message{event: "transcribe", payload: {:binary, payload}},
        socket
      ) do
    Nx.from_binary(payload, :f32) |> IO.inspect()
    {:noreply, socket}
  end
end
