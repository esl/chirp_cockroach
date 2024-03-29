defmodule ChirpCockroach.Chats.Message do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  schema "chat_messages" do
    field :text, :string
    field :audio_transcription, :string
    field :file_path, :string
    field :kind, Ecto.Enum, values: ~w(text voice event image transcription)a
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

  def transcription_changeset(message, attrs) do
    cast(message, attrs, [:audio_transcription])
  end
end
