defmodule ChirpCockroachQl.Resolvers.Auth do
  alias ChirpCockroach.Accounts
  def login(_, args, _) do
    Accounts.create_api_token(args)
  end

  def register(_, args, _) do
    case Accounts.register_user(args) do
      {:ok, user} -> {:ok, user}
      {:error, %Ecto.Changeset{}} ->
        {:error, :invalid_payload}
    end
  end

  def get_current_user(_, _, %{context: context}) do
    {:ok, Map.get(context, :current_user)}
  end

  def logout(_, %{token: token}, _) do
    token
    |> String.replace_prefix("Bearer ", "")
    |> Accounts.delete_user_api_token()

    {:ok, token}
  end
end
