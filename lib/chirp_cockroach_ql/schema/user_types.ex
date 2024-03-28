defmodule ChirpCockroachQl.Schema.UserTypes do
  use Absinthe.Schema.Notation

  object :user do
    field :id, non_null(:id)
    field :email, non_null(:string)
    field :nickname, non_null(:string)
  end
end
