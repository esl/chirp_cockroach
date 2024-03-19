defmodule ChirpCockroachQl.Resolvers.Timeline do
  alias ChirpCockroach.Timeline

  def post_author(%{username: nickname}, _args, _resolution) do
    {:ok, %{id: Ecto.UUID.generate(), nickname: nickname}}
  end

  def list_posts(_parent, _args, _resolution) do
    {:ok, Timeline.list_posts()}
  end

  def create_post(_parent, args, _resolution) do
    Timeline.create_post(args)
  end
end
