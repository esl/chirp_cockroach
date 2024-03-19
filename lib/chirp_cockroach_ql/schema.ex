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
  end
end
