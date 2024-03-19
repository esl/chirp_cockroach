defmodule ChirpCockroachQl.Timeline.CreatePostTest do
  use ChirpCockroachWeb.ConnCase

  @query """
  mutation create_post($body: String!) {
    createPost(body:$body) {
      id,
      body,
      likesCount,
      repostsCount,
      author {
        nickname
      }
    }
  }
  """

  describe "mutation: create_post" do
    test "it creates a post", %{conn: conn} do
      conn =
        post(conn, "/api/graphql", %{
          "query" => @query,
          "variables" => %{body: "Post from test"}
        })

      assert %{"data" => %{"createPost" => post}} = json_response(conn, 200)
      assert %{
        "id" => _,
        "body" => "Post from test",
        "likesCount" => 0,
        "repostsCount" => 0,
        "author" => %{
          "nickname" => "username"
        }
      } = post
    end
  end
end
