defmodule ChirpCockroach.VideoTest do
  use ChirpCockroach.DataCase

  alias ChirpCockroach.Video

  describe "video_rooms" do
    alias ChirpCockroach.Video.Room

    import ChirpCockroach.VideoFixtures

    @invalid_attrs %{name: nil}

    test "list_video_rooms/0 returns all video_rooms" do
      room = room_fixture()
      assert Video.list_video_rooms() == [room]
    end

    test "get_room!/1 returns the room with given id" do
      room = room_fixture()
      assert Video.get_room!(room.id) == room
    end

    test "create_room/1 with valid data creates a room" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Room{} = room} = Video.create_room(valid_attrs)
      assert room.name == "some name"
    end

    test "create_room/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Video.create_room(@invalid_attrs)
    end

    test "update_room/2 with valid data updates the room" do
      room = room_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Room{} = room} = Video.update_room(room, update_attrs)
      assert room.name == "some updated name"
    end

    test "update_room/2 with invalid data returns error changeset" do
      room = room_fixture()
      assert {:error, %Ecto.Changeset{}} = Video.update_room(room, @invalid_attrs)
      assert room == Video.get_room!(room.id)
    end

    test "delete_room/1 deletes the room" do
      room = room_fixture()
      assert {:ok, %Room{}} = Video.delete_room(room)
      assert_raise Ecto.NoResultsError, fn -> Video.get_room!(room.id) end
    end

    test "change_room/1 returns a room changeset" do
      room = room_fixture()
      assert %Ecto.Changeset{} = Video.change_room(room)
    end
  end
end
