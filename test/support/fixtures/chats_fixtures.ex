defmodule ChirpCockroach.ChatsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ChirpCockroach.Chats` context.
  """

  @doc """
  Generate a room.
  """
  def room_fixture(user, attrs \\ %{}) do
    attrs = Enum.into(attrs, %{name: "Some Name"})
    {:ok, room} = ChirpCockroach.Chats.create_room(user, attrs)

    room
  end

  def participant_fixture(room, user) do
    {:ok, participant} = ChirpCockroach.Chats.join_room(user, room)

    participant
  end

  def text_message_fixture(room, user, text) do
    {:ok, message} = ChirpCockroach.Chats.send_to_room(user, room, %{text: text})

    message
  end
end
