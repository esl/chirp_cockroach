defmodule ChirpCockroach.Chats.Participant do
  use Ecto.Schema
  import Ecto.Changeset

  schema "chat_participants" do
    belongs_to(:user, ChirpCockroach.Accounts.User)
    field :room_id, :id

    timestamps()
  end

  @doc false
  def changeset(participant, attrs) do
    participant
    |> cast(attrs, [])
    |> validate_required([])
  end
end
