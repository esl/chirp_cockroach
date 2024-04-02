defmodule ChirpCockroachQl.Socket do
  use Phoenix.Socket

  use Absinthe.Phoenix.Socket,
    schema: ChirpCockroachQl.Schema

  def id(_socket), do: nil
end
