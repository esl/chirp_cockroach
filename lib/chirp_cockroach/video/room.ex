defmodule ChirpCockroach.Video.Room do
  use Ecto.Schema
  import Ecto.Changeset

  schema "video_rooms" do
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(room, attrs) do
    room
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
