defmodule ChirpCockroachQl.Schema.TimelineTypes do
  use Absinthe.Schema.Notation

  object :author do
    field :nickname, :string
  end

  object :post do
    field :id, :id
    field :likes_count, :integer
    field :reposts_count, :integer
    field :body, :string

    field :author, :author do
      resolve(&ChirpCockroachQl.Resolvers.Timeline.post_author/3)
    end
  end
end
