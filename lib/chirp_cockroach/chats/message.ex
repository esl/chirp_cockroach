defmodule ChirpCockroach.Chats.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "chat_messages" do
    field :text, :string
    field :kind, Ecto.Enum, values: ~w(text transcription event)a
    belongs_to(:user, ChirpCockroach.Accounts.User)
    belongs_to(:room, ChirpCockroach.Chats.Room)

    timestamps()
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:text])
    |> validate_required([:text, :kind])
  end
end
