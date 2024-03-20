defmodule ChirpCockroachQl.Schema do
  use Absinthe.Schema
  import_types ChirpCockroachQl.Schema.TimelineTypes

  alias ChirpCockroachQl.Resolvers

  query do

    @desc "Get all posts"
    field :posts, list_of(:post) do
      resolve &Resolvers.Timeline.list_posts/3
    end

  end

  mutation do
    @desc "Create a Post"
    field :create_post, type: :post do
      arg :body, non_null(:string)

      resolve &Resolvers.Timeline.create_post/3
    end

    field :update_post, type: :post do
      arg :id, non_null(:id)
      arg :body, non_null(:string)

      resolve &Resolvers.Timeline.update_post/3
    end

    field :delete_post, type: :post do
      arg :id, non_null(:id)

      resolve &Resolvers.Timeline.delete_post/3
    end
  end

  subscription do
    @desc "Post created"
    field :post_created, type: :post do
      config fn _, _ ->
        {:ok, topic: "posts:*"}
      end
    end

    @desc "Post Updated"
    field :post_updated, type: :post do
      config fn _, _ ->
        {:ok, topic: "posts:*"}
      end
    end

    @desc "Post deleted"
    field :post_deleted, type: :post do
      config fn _, _ ->
        {:ok, topic: "posts:*"}
      end
    end
  end
end
