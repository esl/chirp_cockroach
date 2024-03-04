defmodule ChirpCockroach.Audio.Whisper do
  use GenServer

  require Logger

  defstruct [:whisper, :serving]

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    {:ok, whisper} = Bumblebee.load_model({:hf, "openai/whisper-tiny"})
    {:ok, featurizer} = Bumblebee.load_featurizer({:hf, "openai/whisper-tiny"})
    {:ok, tokenizer} = Bumblebee.load_tokenizer({:hf, "openai/whisper-tiny"})
    {:ok, generation_config} = Bumblebee.load_generation_config({:hf, "openai/whisper-tiny"})

    Logger.info("[ChirpCockroach.Audio.Whisper] Whisper Model Loaded")

    serving =
      Bumblebee.Audio.speech_to_text_whisper(whisper, featurizer, tokenizer, generation_config,
        defn_options: [compiler: EXLA]
      )

    Logger.info("[ChirpCockroach.Audio.Whisper] Serving initiated")

    {:ok,
     %__MODULE__{
       whisper: whisper,
       serving: serving
     }}
  end

  def handle_call(:get, _, state) do
    {:reply, {:ok, state}, state}
  end

  ## Public API

  def get() do
    GenServer.call(__MODULE__, :get)
  end
end
