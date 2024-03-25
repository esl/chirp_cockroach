defmodule ChirpCockroach.Timeline.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field(:body, :string)
    field(:likes_count, :integer, default: 0)
    field(:reposts_count, :integer, default: 0)

    belongs_to(:user, ChirpCockroach.Accounts.User)

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:body])
    |> validate_required([:body, :user_id])
    |> validate_length(:body, min: 2, max: 250)
  end
end
