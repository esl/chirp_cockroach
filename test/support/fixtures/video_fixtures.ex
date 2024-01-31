defmodule ChirpCockroach.VideoFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ChirpCockroach.Video` context.
  """

  @doc """
  Generate a room.
  """
  def room_fixture(attrs \\ %{}) do
    {:ok, room} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> ChirpCockroach.Video.create_room()

    room
  end
end
