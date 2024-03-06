defmodule ChirpCockroachWeb.IrcLive.SendMessageComponent do
  use ChirpCockroachWeb, :live_component

  alias ChirpCockroach.Chats

  @impl true
  def update(%{message: message} = assigns, socket) do
    changeset = Chats.Message.changeset(message, %{})

    {:ok,
     socket
     |> assign(assigns)
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

  def handle_event(first, second, socket) do
    raise(%{
      first: first,
      second: second
    })

    {:noreply, socket}
  end
end
