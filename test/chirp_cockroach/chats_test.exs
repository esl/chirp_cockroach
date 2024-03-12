defmodule ChirpCockroach.ChatsTest do
  use ChirpCockroach.DataCase

  alias ChirpCockroach.Chats

  import ChirpCockroach.AccountsFixtures
  import ChirpCockroach.ChatsFixtures

  setup do
    user = user_fixture()

    [user: user]
  end

  describe "list_chat_rooms/0" do
    test "it returns chat rooms", %{user: user} do
      _first_room = room_fixture(user, name: "First Room")
      _second_room = room_fixture(user, name: "Second Room")

      assert [_, _] = Chats.list_chat_rooms()
    end
  end

  describe "get_room_messages/1" do
    setup %{user: user} do
      room = room_fixture(user, %{name: "Room"})

      [room: room]
    end

    test "it returns room messages", %{room: room, user: user} do
      _first_message = text_message_fixture(room, user, "Message 1")
      _second_message = text_message_fixture(room, user, "Message 2")

      assert [_, _] = Chats.get_room_messages(room)
    end
  end

  describe "list_user_rooms/1" do

  end

  describe "get_room!/1" do

  end

  describe "create_room/2" do
  end

  describe "join_room/2" do

  end

  describe "leave_room/2" do
  end

  describe "send_to_room/3" do

  end
end
