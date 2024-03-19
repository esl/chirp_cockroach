defmodule ChirpCockroachQl.Timeline.PostsTest do
  use ChirpCockroachWeb.ConnCase

  import ChirpCockroach.TimelineFixtures

  @query """
  query list_posts {
    posts {
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
    test "it lists all posts", %{conn: conn} do
      post_1 = post_fixture(body: "First Post")
      post_2 = post_fixture(body: "Second Post")

      conn =
        post(conn, "/api/graphql", %{
          "query" => @query,
          "variables" => %{}
        })

      assert %{"data" => %{"posts" => posts}} = json_response(conn, 200)
      assert [
        %{
          "id" => Integer.to_string(post_2.id),
          "body" => post_2.body,
          "likesCount" => post_2.likes_count,
          "repostsCount" => post_2.reposts_count,
          "author" => %{
            "nickname" => "username"
          }
        },
        %{
          "id" => Integer.to_string(post_1.id),
          "body" => post_1.body,
          "likesCount" => post_1.likes_count,
          "repostsCount" => post_1.reposts_count,
          "author" => %{
            "nickname" => "username"
          }
        }
      ] == posts
    end
  end
end
