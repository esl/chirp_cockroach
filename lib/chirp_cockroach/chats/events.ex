defmodule ChirpCockroach.Chats.Events do
  defmodule RoomCreated do
    defstruct [:room]
  end

  defmodule RoomJoinedByUser do
    defstruct [:room, :user]
  end

  defmodule RoomLeftByUser do
    defstruct [:room, :user]
  end

  defmodule NewMessageInRoom do
    defstruct [:room, :message]
  end
end
