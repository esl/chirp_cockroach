defmodule ChirpCockroach.Video.Peer do
  use Ecto.Schema

  embedded_schema do
    field(:name)
    field(:pid)
  end
end
