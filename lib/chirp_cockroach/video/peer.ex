defmodule ChirpCockroach.Video.Peer do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:peer_id, :string, []}
  embedded_schema do
    field(:room_id, :integer)
    field(:user_id, :integer)
    field(:pid)
    field(:name)
  end

  def changeset(peer \\ %__MODULE__{}, attrs) do
    peer
    |> cast(attrs, [:peer_id, :room_id, :user_id, :name])
    |> validate_required([:room_id, :user_id, :name])
  end
end
