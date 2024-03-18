defmodule ChirpCockroach.Timeline do
  @moduledoc """
  The Timeline context.
  """

  import Ecto.Query, warn: false
  alias ChirpCockroach.Repo

  alias ChirpCockroach.Timeline.Post

  @doc """
  Returns the list of posts.

  ## Examples

      iex> list_posts()
      [%Post{}, ...]

  """
  def list_posts do
    Post
    |> order_by(desc: :id)
    |> Repo.all()
    |> Repo.preload(:user)
  end

  @doc """
  Gets a single post.

  Raises `Ecto.NoResultsError` if the Post does not exist.

  ## Examples

      iex> get_post!(123)
      %Post{}

      iex> get_post!(456)
      ** (Ecto.NoResultsError)

  """
  def get_post!(id) do
    Post
    |> Repo.get!(id)
    |> Repo.preload(:user)
  end

  @doc """
  Creates a post.
  """
  def create_post(user, attrs \\ %{}) do
    require Logger
    Logger.info(user)
    %Post{user_id: user.id}
    |> Post.changeset(attrs)
    |> Repo.insert()
    |> broadcast(:post_created)
  end

  @doc """
  Updates a post.
  """
  def update_post(user, %Post{} = post, attrs) do
    with :ok <- authorize(user, post) do
      post
      |> Post.changeset(attrs)
      |> Repo.update()
      |> broadcast(:post_updated)
    end
  end

  @doc """
  Deletes a post.
  """
  def delete_post(user, %Post{} = post) do
    with :ok <- authorize(user, post) do
      post
      |> Repo.delete()
      |> broadcast(:post_deleted)
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post changes.

  ## Examples

      iex> change_post(post)
      %Ecto.Changeset{data: %Post{}}

  """
  def change_post(%Post{} = post, attrs \\ %{}) do
    Post.changeset(post, attrs)
  end

  defp authorize(%{id: user_id}, %Post{user_id: user_id}), do: :ok
  defp authorize(_, _), do: {:error, :unauthorized}

  def subscribe do
    Phoenix.PubSub.subscribe(ChirpCockroach.PubSub, "posts")
  end

  def inc_likes(%Post{id: post_id}) do
    {1, [post]} =
      Post
      |> where(id: ^post_id)
      |> select([p], p)
      |> Repo.update_all(inc: [likes_count: 1])

    broadcast({:ok, post}, :post_updated)
  end

  def inc_reposts(%Post{id: post_id}) do
    {1, [post]} =
      Post
      |> where(id: ^post_id)
      |> select([p], p)
      |> Repo.update_all(inc: [reposts_count: 1])

    broadcast({:ok, post}, :post_updated)
  end

  defp broadcast({:error, _response} = error, _event), do: error

  defp broadcast({:ok, post}, event) do
    Phoenix.PubSub.broadcast(ChirpCockroach.PubSub, "posts", {event, post})
    {:ok, post}
  end
end
