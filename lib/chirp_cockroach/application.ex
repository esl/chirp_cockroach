defmodule ChirpCockroach.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  defp whisper_serving do
    {:ok, model_info} = Bumblebee.load_model({:hf, "openai/whisper-tiny"})
    {:ok, featurizer} = Bumblebee.load_featurizer({:hf, "openai/whisper-tiny"})
    {:ok, tokenizer} = Bumblebee.load_tokenizer({:hf, "openai/whisper-tiny"})
    {:ok, generation_config} = Bumblebee.load_generation_config({:hf, "openai/whisper-tiny"})

    Bumblebee.Audio.speech_to_text_whisper(model_info, featurizer, tokenizer, generation_config,
      compile: [batch_size: 4],
      defn_options: [compiler: EXLA]
    )
  end

  defp roberta_serving do
    {:ok, roberta} = Bumblebee.load_model({:hf, "deepset/roberta-base-squad2"})
    {:ok, tokenizer} = Bumblebee.load_tokenizer({:hf, "FacebookAI/roberta-base"})

    Bumblebee.Text.question_answering(roberta, tokenizer)
  end

  defp gpt_2 do
    {:ok, gpt2} = Bumblebee.load_model({:hf, "openai-community/gpt2"})
    {:ok, tokenizer} = Bumblebee.load_tokenizer({:hf, "openai-community/gpt2"})
    {:ok, generation_config} = Bumblebee.load_generation_config({:hf, "openai-community/gpt2"})

    Bumblebee.Text.generation(gpt2, tokenizer, generation_config)
  end

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      ChirpCockroach.Repo,
      # Run migrations
      ChirpCockroach.Migrator,
      # Start the Telemetry supervisor
      ChirpCockroachWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: ChirpCockroach.PubSub},
      # Start the Endpoint (http/https)
      ChirpCockroachWeb.Endpoint,
      # Start a worker by calling: ChirpCockroach.Worker.start_link(arg)
      # {ChirpCockroach.Worker, arg},
      # TODO(rafalskorupa): Add supervisors
      {Nx.Serving,
       serving: whisper_serving(), name: ChirpCockroach.Serving.Whisper, batch_timeout: 100},
      {Nx.Serving,
       serving: roberta_serving(), name: ChirpCockroach.Serving.Roberta, batch_timeout: 100},
      {Nx.Serving, serving: gpt_2(), name: ChirpCockroach.Serving.Gpt2, batch_timeout: 100}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ChirpCockroach.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ChirpCockroachWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
