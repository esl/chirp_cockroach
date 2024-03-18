defmodule ChirpCockroach.Repo.Migrations.AddUserIdToPosts do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      remove :username, :string, default: "username"
    end
  end
end
