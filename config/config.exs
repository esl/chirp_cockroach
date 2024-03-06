# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :nx, default_backend: EXLA.Backend

config :chirp_cockroach,
  ecto_repos: [ChirpCockroach.Repo]

config :chirp_cockroach, ChirpCockroach.Mailer, adapter: Swoosh.Adapters.Local

# Configures the endpoint
config :chirp_cockroach, ChirpCockroachWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: ChirpCockroachWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: ChirpCockroach.PubSub,
  live_view: [signing_salt: "nTqni1f/"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.29",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2018 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ],
  stream: [
    args: ~w(js/stream.js --bundle --platform=node --outdir=../priv/static/assets),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ],
  whisper: [
    args: ~w(js/whisper.js --bundle --target=es2018 --outdir=../priv/static/assets),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ],
  libstream_worker: [
    args: ~w(js/libstream.worker.js --bundle --platform=node --outdir=../priv/static/assets),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
