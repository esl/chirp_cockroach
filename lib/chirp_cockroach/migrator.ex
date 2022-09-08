defmodule ChirpCockroach.Migrator do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{})
  end

  @impl true
  def init(_) do
    # Check if :chirp_cockroach is started
    {:ok, _} = Application.ensure_all_started(:chirp_cockroach)
    # Get the path to the migration files
    path = Application.app_dir(:my_app, "priv/repo/migrations")
    # Run the Ecto.Migrator
    Ecto.Migrator.run(ChirpCockroach.Repo, path, :up, all: true) |> IO.inspect(label: :RUNNING)
  end
end
