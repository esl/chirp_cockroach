defmodule ChirpCockroach.Repo.Migrations.CreateVideoRooms do
  use Ecto.Migration

  def change do
    create table(:video_rooms) do
      add :name, :string

      timestamps()
    end
  end
end
