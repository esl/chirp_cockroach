defmodule ChirpCockroachWeb.IrcLive.SendMessageComponent do
  use ChirpCockroachWeb, :live_component
  import ChirpCockroachWeb.MultimediaComponents

  alias ChirpCockroach.Chats
  alias ChirpCockroach.Files

  @impl true
  def update(%{message: message} = assigns, socket) do
    changeset = Chats.Message.changeset(message, %{})

    {:ok,
     socket
     |> assign(assigns)
     |> allow_upload(:audio_file, accept: :any, progress: &handle_progress/3, auto_upload: true)
     |> assign(:changeset, changeset)}
  end

  @impl true
def handle_event("validate", %{"message" => message_params}, socket) do
    changeset =
      socket.assigns.message
      |> Chats.Message.changeset(message_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"message" => message_params}, socket) do
    case Chats.send_to_room(socket.assigns.current_user, socket.assigns.room, message_params) do
      {:ok, _room} ->
        changeset = Chats.Message.changeset(%Chats.Message{}, %{})

        {:noreply,
         socket
         |> assign(:message, %Chats.Message{})
         |> assign(:changeset, changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("noop", _, socket) do
    {:noreply, socket}
  end

  defp handle_progress(:audio_file, entry, socket) when entry.done? do
    [file] = consume_uploaded_entries(socket, :audio_file, &process_tmp_audio_file/2)

    {:ok, _} = Chats.send_voice_to_room(socket.assigns.current_user, socket.assigns.room, file)

    {:noreply, socket}
  end

  defp handle_progress(_name, _entry, socket), do: {:noreply, socket}

  defp process_tmp_audio_file(%{path: path} = _info, _entry) do
    upload_id = Ecto.UUID.generate()
    filename = "#{upload_id}.mp3"
    {:ok, %{path: path}} = Files.persist_file(path, "#{upload_id}.mp3")
    {:ok, %{path: path, filename: filename}}
  end
end
