defmodule ChirpCockroach.Ai do

  alias ChirpCockroach.Serving

  def answer_question(question) do
    Serving.Roberta
    |> batched_text_run(%{question: question, context: roberta_context()})
    |> case do
      {:ok, ""} -> {:ok, "I don't know"}
      {:ok, text} -> {:ok, text}
      error -> error
    end
  end

  def gpt_2(text) do
    batched_text_run(Serving.Gpt2, text)
  end

  defp roberta_context do
    ~s/The Amazon rainforest (Portuguese: Floresta Amazônica or Amazônia; Spanish: Selva Amazónica, Amazonía or usually Amazonia; French: Forêt amazonienne; Dutch: Amazoneregenwoud), also known in English as Amazonia or the Amazon Jungle, is a moist broadleaf forest that covers most of the Amazon basin of South America. This basin encompasses 7,000,000 square kilometres (2,700,000 sq mi), of which 5,500,000 square kilometres (2,100,000 sq mi) are covered by the rainforest. This region includes territory belonging to nine nations. The majority of the forest is contained within Brazil, with 60% of the rainforest, followed by Peru with 13%, Colombia with 10%, and with minor amounts in Venezuela, Ecuador, Bolivia, Guyana, Suriname and French Guiana. States or departments in four nations contain "Amazonas" in their names. The Amazon represents over half of the planet's remaining rainforests, and comprises the largest and most biodiverse tract of tropical rainforest in the world, with an estimated 390 billion individual trees divided into 16,000 species./
  end

  defp batched_text_run(serving, data) do
    case Nx.Serving.batched_run(serving, data) do
      %{results: [%{text: text}]} ->
        {:ok, text}
      unexpected -> {:error, {:unexpected_response, unexpected}}
    end
  end
end
