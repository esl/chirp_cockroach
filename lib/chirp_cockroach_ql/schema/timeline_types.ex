defmodule ChirpCockroachQl.Schema.TimelineTypes do
  use Absinthe.Schema.Notation

  object :user do
    field :nickname, :string
  end

  object :post do
    field :id, :id
    field :likes_count, :integer
    field :reposts_count, :integer
    field :body, :string
    field :author, :user do
      resolve &ChirpCockroachQl.Resolvers.Timeline.post_author/3
    end
  end
end
