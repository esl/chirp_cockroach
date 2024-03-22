defmodule ChirpCockroach.Ai do
  alias ChirpCockroach.Serving

  @type ai_error :: {:error, {:unexpected_response, any()}}

  @spec whisper(any()) :: {:ok, String.t()} | ai_error()
  def whisper(input) do
    with %{chunks: chunks} <- Nx.Serving.batched_run(Serving.Whisper, input) do
      {:ok, chunks |> Enum.map_join(& &1.text) |> String.trim()}
    else
      serving_result -> {:error, {:unexpected_response, serving_result}}
    end
  end

  @spec answer_question(String.t()) :: {:ok, String.t()} | ai_error()
  def answer_question(question) do
    Serving.Roberta
    |> batched_text_run(%{question: question, context: roberta_context()})
    |> case do
      {:ok, ""} -> {:ok, "I don't know"}
      {:ok, text} -> {:ok, text}
      error -> error
    end
  end

  @spec gpt_2(String.t()) :: {:ok, String.t()} | ai_error()
  def gpt_2(text) do
    batched_text_run(Serving.Gpt2, text)
  end

  @spec roberta_context() :: String.t()
  defp roberta_context do
    ~s/The Amazon rainforest (Portuguese: Floresta Amazônica or Amazônia; Spanish: Selva Amazónica, Amazonía or usually Amazonia; French: Forêt amazonienne; Dutch: Amazoneregenwoud), also known in English as Amazonia or the Amazon Jungle, is a moist broadleaf forest that covers most of the Amazon basin of South America. This basin encompasses 7,000,000 square kilometres (2,700,000 sq mi), of which 5,500,000 square kilometres (2,100,000 sq mi) are covered by the rainforest. This region includes territory belonging to nine nations. The majority of the forest is contained within Brazil, with 60% of the rainforest, followed by Peru with 13%, Colombia with 10%, and with minor amounts in Venezuela, Ecuador, Bolivia, Guyana, Suriname and French Guiana. States or departments in four nations contain "Amazonas" in their names. The Amazon represents over half of the planet's remaining rainforests, and comprises the largest and most biodiverse tract of tropical rainforest in the world, with an estimated 390 billion individual trees divided into 16,000 species./
  end

  @spec batched_text_run(module(), any()) :: {:ok, String.t()} | ai_error()
  defp batched_text_run(serving, data) do
    case Nx.Serving.batched_run(serving, data) do
      %{results: [%{text: text}]} ->
        {:ok, text}

      unexpected ->
        {:error, {:unexpected_response, unexpected}}
    end
  end
end
