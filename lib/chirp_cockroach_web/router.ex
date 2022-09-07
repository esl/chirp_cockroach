defmodule ChirpCockroachWeb.Router do
  use ChirpCockroachWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, {ChirpCockroachWeb.LayoutView, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", ChirpCockroachWeb do
    pipe_through(:browser)

    live("/posts", PostLive.Index, :index)
    live("/posts/new", PostLive.Index, :new)
    live("/posts/:id/edit", PostLive.Index, :edit)

    live("/posts/:id", PostLive.Show, :show)
    live("/posts/:id/show/edit", PostLive.Show, :edit)

    get("/", PageController, :index)
  end

  # Other scopes may use custom stacks.
  # scope "/api", ChirpCockroachWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through(:browser)

      live_dashboard("/dashboard", metrics: ChirpCockroachWeb.Telemetry)
    end
  end
end
