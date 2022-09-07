defmodule ChirpCockroach.Repo do
  use Ecto.Repo,
    otp_app: :chirp_cockroach,
    adapter: Ecto.Adapters.Postgres
end
