defmodule ChirpCockroachQl.Schema do
  use Absinthe.Schema
  import_types(ChirpCockroachQl.Schema.TimelineTypes)
  import_types(ChirpCockroachQl.Schema.UserTypes)

  alias ChirpCockroachQl.Resolvers

  query do
    @desc "Get all posts"
    field :posts, list_of(:post) do
      resolve(&Resolvers.Timeline.list_posts/3)
    end

    @desc "Get current user"
    field :current_user, :user do
      resolve(&Resolvers.Auth.get_current_user/3)
    end
  end

  mutation do
    @desc "Login"
    field :login, :string do
      arg(:email, :string)
      arg(:password, :string)

      resolve(&Resolvers.Auth.login/3)
    end

    @desc "Logout"
    field :logout, :string do
      arg(:token, non_null(:string))

      resolve &Resolvers.Auth.logout/3
    end

    @desc "Register"
    field :register, :user do
      arg(:email, non_null(:string))
      arg(:password, non_null(:string))
      arg(:nickname, non_null(:string))

      resolve &Resolvers.Auth.register/3
    end

    @desc "Create a Post"
    field :create_post, type: :post do
      arg(:body, non_null(:string))

      resolve(&Resolvers.Timeline.create_post/3)
    end

    field :update_post, type: :post do
      arg(:id, non_null(:id))
      arg(:body, non_null(:string))

      resolve(&Resolvers.Timeline.update_post/3)
    end

    field :delete_post, type: :post do
      arg(:id, non_null(:id))

      resolve(&Resolvers.Timeline.delete_post/3)
    end
  end

  subscription do
    @desc "Post created"
    field :post_created, type: :post do
      config(fn _, _ ->
        {:ok, topic: "posts:*"}
      end)
    end

    @desc "Post Updated"
    field :post_updated, type: :post do
      config(fn _, _ ->
        {:ok, topic: "posts:*"}
      end)
    end

    @desc "Post deleted"
    field :post_deleted, type: :post do
      config(fn _, _ ->
        {:ok, topic: "posts:*"}
      end)
    end
  end
end
