defmodule ChirpCockroachWeb.PageController do
  use ChirpCockroachWeb, :controller

  def index(conn, _params) do
    redirect(conn, to: Routes.post_index_path(conn, :index))
  end
end
