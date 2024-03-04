defmodule ChirpCockroachWeb.Router do
  use ChirpCockroachWeb, :router

  import ChirpCockroachWeb.UserAuth

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
    get("/", PageController, :index)

    live "/video_rooms", RoomLive.Index, :index
    live "/video_rooms/new", RoomLive.Index, :new
    live "/video_rooms/:id/edit", RoomLive.Index, :edit

    live "/video_rooms/:id", RoomLive.Show, :show
    live "/video_rooms/:id/show/edit", RoomLive.Show, :edit
    live "/video_rooms/:id/show/join", RoomLive.Show, :join
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

  ## Authentication routes

  scope "/", ChirpCockroachWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{ChirpCockroachWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", ChirpCockroachWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{ChirpCockroachWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  scope "/", ChirpCockroachWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{ChirpCockroachWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
