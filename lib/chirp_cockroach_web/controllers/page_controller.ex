defmodule ChirpCockroachWeb.PageController do
  use ChirpCockroachWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
