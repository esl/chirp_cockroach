defmodule ChirpCockroach.Repo.Migrations.CreateChatMessages do
  use Ecto.Migration

  def change do
    create table(:chat_messages) do
      add :text, :text

      add :file_path, :string
      add :user_id, references(:users, on_delete: :nothing)
      add :room_id, references(:chat_rooms, on_delete: :nothing)
      add :kind, :string

      add :audio_transcription, :text

      timestamps()
    end

    create index(:chat_messages, [:user_id])
    create index(:chat_messages, [:room_id])
  end
end
