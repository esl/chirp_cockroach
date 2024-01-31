defmodule ChirpCockroach.Repo.Migrations.CreateVideoPeers do
  use Ecto.Migration

  def change do
    create table(:video_peers) do
      add :peer_id, :string
      add :name, :string
      add :room, references(:video_rooms, on_delete: :nothing)

      timestamps()
    end

    create index(:video_peers, [:room])
  end
end
