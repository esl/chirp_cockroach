defmodule ChirpCockroach.Video.Call do
  use GenServer
  use Ecto.Schema

  alias ChirpCockroach.Video

  embedded_schema do
    field(:room_id)
    embeds_many(:peers, ChirpCockroach.Video.Peer)
  end

  @impl true
  def init(room_id) do
    {:ok, %__MODULE__{room_id: room_id, peers: []}}
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
    peer = %Video.Peer{peer | room_id: state.room_id}

    peers = [peer | peers]
    state = %__MODULE__{state | peers: peers}

    Process.monitor(peer.pid)
    ChirpCockroach.Events.publish(%Video.Events.VideoStreamAdded{peer: peer})

    state
  end

  defp remove_participant(state, pid) do
    peer = Enum.find(state.peers, &(&1.pid == pid))
    peers = state.peers |> Enum.reject(&(&1.pid == pid))
    state = %__MODULE__{state | peers: peers}

    if peer, do: ChirpCockroach.Events.publish(%Video.Events.VideoStreamRemoved{peer: peer})

    state
  end

  ## Public API

  def join(%Video.Peer{} = peer, room) do
    GenServer.call(identity(room), {:join, peer})
  end

  def get_call(room) do
    GenServer.call(identity(room), :info)
  end

  def identity(%ChirpCockroach.Chats.Room{} = room) do
    case GenServer.start(__MODULE__, room.id, name: {:global, "video_call-#{room.id}"}) do
      {:ok, pid} ->
        pid

      {:error, {:already_started, pid}} ->
        pid
    end
  end
end
