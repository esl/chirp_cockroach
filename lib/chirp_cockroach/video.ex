defmodule ChirpCockroach.Video do
  @moduledoc """
  The Video context.
  """

  alias ChirpCockroach.Video

  def subscribe(room_id) do
    Phoenix.PubSub.subscribe(ChirpCockroach.PubSub, "room:#{room_id}")
  end

  def broadcast(%{room_id: room_id}, event) do
    Phoenix.PubSub.broadcast(ChirpCockroach.PubSub, "room:#{room_id}", event)
  end

  def start_stream(user, room, peer_id) do
    %{room_id: room.id, peer_id: peer_id, user_id: user.id, name: user.nickname}
    |> Video.Peer.changeset()
    |> Ecto.Changeset.apply_action!(:build)
    |> Video.Call.join(room)
  end
end
