defmodule ChirpCockroach.Migrator do
  @moduledoc """
  This module is for convenience only, so some checks or proper
  guards are ommited.

  USE ON DEV OR LOCAL CONTAINERS only.
  """
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{})
  end

  @impl true
  def init(_) do
    # Get the path to the migration files
    path = Application.app_dir(:chirp_cockroach, "priv/repo/migrations")

    # Run the Ecto.Migrator
    Ecto.Migrator.run(ChirpCockroach.Repo, path, :up, all: true)

    {:ok, []}
  end
end
