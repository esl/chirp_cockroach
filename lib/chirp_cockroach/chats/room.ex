defmodule ChirpCockroach.Chats.Room do
  use Ecto.Schema
  import Ecto.Changeset

  schema "chat_rooms" do
    field :name, :string
    belongs_to(:user, ChirpCockroach.Accounts.User)

    has_many(:participants, ChirpCockroach.Chats.Participant)
    has_many(:users, through: [:participants, :user])
    has_many(:messages, ChirpCockroach.Chats.Message)

    timestamps()
  end

  @doc false
  def changeset(room, attrs) do
    room
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
