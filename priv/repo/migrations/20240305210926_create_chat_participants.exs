defmodule ChirpCockroach.Repo.Migrations.CreateChatParticipants do
  use Ecto.Migration

  def change do
    create table(:chat_participants) do
      add :user_id, references(:users, on_delete: :nothing)
      add :room_id, references(:chat_rooms, on_delete: :nothing)

      timestamps()
    end

    create index(:chat_participants, [:user_id])
    create index(:chat_participants, [:room_id])
    create unique_index(:chat_participants, [:room_id, :user_id])
  end
end
