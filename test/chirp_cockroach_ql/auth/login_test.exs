defmodule ChirpCockroachQl.Auth.LoginTest do
  use ChirpCockroachWeb.ConnCase

  import ChirpCockroach.AccountsFixtures

  @query """
  mutation login($email: String!, $password: String!) {
    login(email: $email, password: $password)
  }
  """

  @email "joe.doe@example.com"
  @password "1234P@ssw0rd!"

  describe "mutation: login" do
    test "it returns authentication token", %{conn: conn} do
      %{id: user_id} = user_fixture(email: @email, password: @password)

      conn = post(conn, "/api/graphql", %{
        "query" => @query,
        "variables" => %{email: @email , password: @password}
      })

      assert %{"data" => %{"login" => token}} = json_response(conn, 200)
      assert token
      assert {:ok, %{id: ^user_id}} = ChirpCockroach.Accounts.fetch_user_by_api_token(token)
    end

    test "when unauthorized", %{conn: conn} do
      conn = post(conn, "/api/graphql", %{
        "query" => @query,
        "variables" => %{email: @email , password: @password}
      })

      assert %{"data" => %{"login" => nil}, "errors" => [%{"message" => "invalid_credentials"}]} = json_response(conn, 200)
    end
  end
end
