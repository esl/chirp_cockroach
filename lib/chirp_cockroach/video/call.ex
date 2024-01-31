defmodule ChirpCockroach.Video.Call do
  use GenServer
  use Ecto.Schema

  alias ChirpCockroach.Video

  embedded_schema do
    belongs_to(:room, ChirpCockroach.Video.Room)
    embeds_many(:peers, ChirpCockroach.Video.Peer)
  end

  @impl true
  def init(%Video.Room{} = room) do
    {:ok, %__MODULE__{room: room, peers: []}}
  end

  @impl true
  def handle_call({:join, %Video.Peer{} = peer}, {pid, _}, %__MODULE__{} = state) do
    peer = %ChirpCockroach.Video.Peer{peer | pid: pid}
    state = add_participant(state, peer)

    {:reply, {:ok, state}, state}
  end

  def handle_call(:info, _from, call) do
    {:reply, call, call}
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, pid, _reason}, state) do
    {:noreply, remove_participant(state, pid)}
  end

  defp add_participant(%{peers: peers} = state, peer) do
    peers = [peer | peers]
    state = %__MODULE__{state | peers: peers}

    Process.monitor(peer.pid)
    Video.broadcast(state.room, {:participant_joined, peer})

    state
  end

  defp remove_participant(state, pid) do
    peer = Enum.find(state.peers, & &1.pid == pid)
    peers = state.peers |> Enum.reject(&(&1.pid == pid))
    state = %__MODULE__{state | peers: peers}

    if peer, do: Video.broadcast(state.room, {:participant_left, peer})

    state
  end

  ## Public API

  def join(%Video.Room{} = room, %Video.Peer{} = peer) do
    GenServer.call(identity(room), {:join, peer})
  end

  def get_call(%Video.Room{} = room) do
    GenServer.call(identity(room), :info)
  end

  def identity(%Video.Room{} = room) do
    case GenServer.start(__MODULE__, room, name: {:global, room.id}) do
      {:ok, pid} ->
        pid

      {:error, {:already_started, pid}} ->
        pid
    end
  end
end

# room = ChirpCockroach.Video.get_room!(937337471011454977)
# ChirpCockroach.Video.Call.reset_call(room)
# peer = %ChirpCockroach.Video.Peer{id: "123"}
# ChirpCockroach.Video.Call.join(room, peer)
# ChirpCockroach.Video.get_call(room)
# ChirpCockroach.Video.get_room_participants!(937337471011454977)
