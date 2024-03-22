defmodule ChirpCockroach.Video.Events do
  defmodule VideoStreamAdded do
    defstruct [:peer]
  end

  defmodule VideoStreamRemoved do
    defstruct [:peer]
  end
end
