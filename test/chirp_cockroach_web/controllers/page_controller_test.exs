defmodule ChirpCockroachWeb.PageControllerTest do
  use ChirpCockroachWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")

    assert html_response(conn, 302)
  end
end
