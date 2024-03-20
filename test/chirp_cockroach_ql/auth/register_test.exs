defmodule ChirpCockroachQl.Auth.RegisterTest do
  use ChirpCockroachWeb.ConnCase

  import ChirpCockroach.AccountsFixtures

  @query """
  mutation register($email: String!, $password: String!, $nickname: String!) {
    register(email: $email, password: $password, nickname: $nickname) {
      id,
      nickname,
      email
    }
  }
  """

  @nickname "Joe Doe"
  @email "joe.doe@example.com"
  @password "1234P@ssw0rd!"

  describe "mutation: login" do
    test "it returns authentication token", %{conn: conn} do
      conn = post(conn, "/api/graphql", %{
        "query" => @query,
        "variables" => %{nickname: @nickname, email: @email , password: @password}
      })

      assert %{"data" => %{"register" => user}} = json_response(conn, 200)
      assert %{"id" => _, "email" => @email, "nickname" => @nickname} = user
      assert ChirpCockroach.Accounts.get_user_by_email(@email)
    end

    test "when email is already taken", %{conn: conn} do
      user_fixture(email: @email)

      conn = post(conn, "/api/graphql", %{
        "query" => @query,
        "variables" => %{nickname: @nickname, email: @email , password: @password}
      })

      assert %{"data" => %{"register" => nil}, "errors" => [%{"message" => "invalid_payload"}]} = json_response(conn, 200)
    end
  end
end
