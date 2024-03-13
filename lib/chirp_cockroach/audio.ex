defmodule ChirpCockroach.Audio do
  @moduledoc """

  Assuming sample.mp3 is in root directory of project

  ChirpCockroach.Audio.whisper("./sample.mp3")

  """

  def transcribe(input) do
    output = Nx.Serving.batched_run(ChirpCockroach.Serving.Whisper, input)
    transcription = output.chunks |> Enum.map_join(& &1.text) |> String.trim()
    {:ok, %{transcription: transcription}}
  end

  @doc """
  whisper("sample.mp3") will IO.puts a transcribed text with timestamps
  """
  def whisper(path, func \\ &print/2, chunk_time \\ 60) do
    duration = audio_duration(path)

    0..duration//chunk_time
    |> Task.async_stream(
      fn timestamp ->
        {_, data} = convert_audio(path, timestamp, chunk_time)

        {timestamp, whisperify(data)}
      end,
      max_concurrency: 16,
      timeout: :infinity
    )
    |> Enum.map(fn {
                     :ok,
                     {timestamp, result}
                   } ->
      func.(timestamp, result)
    end)
  end

  def print(timestamp, %{chunks: [%{text: text}]}) do
    IO.puts("#{timestamp}: #{text}")
  end

  @doc """
  Input might be an Nx tensors or {:file, "path/to/file.mp3"}
  """
  def whisperify(input) do
    {:ok, %{serving: serving}} = ChirpCockroach.Audio.Whisper.get()

    Nx.Serving.run(serving, input)
  end

  @doc """
  Slices audio from timestamp to timestamp + chunk_time (in seconds)
  Returns {timestamp, Nx tensor list}
  """
  @spec convert_audio(String.t(), number(), number()) :: {number(), Nx.Tensor.t()}
  def convert_audio(path, timestamp, chunk_time) do
    args = ~w(-ac 1 -ar 16k -f f32le -ss #{timestamp} -t #{chunk_time} -v quiet -)
    {data, 0} = System.cmd("ffmpeg", ["-i", path] ++ args)

    {timestamp, Nx.from_binary(data, :f32)}
  end

  def blob_to_audio(path, destination) do
    args = ~w(-ac 1 -ar 16k -f f32le -v)
    {data, _} = System.cmd("ffmpeg", ["-i", path] ++ args)
  end

  @doc """
  Returns audio duration of file under given path rounded up to integer
  """
  @spec audio_duration(String.t()) :: integer()
  def audio_duration(path) do
    {time_in_seconds, _error} =
      System.cmd("ffprobe", [
        "-i",
        path,
        "-v",
        "quiet",
        "-show_entries",
        "format=duration",
        "-hide_banner",
        "-of",
        "default=noprint_wrappers=1:nokey=1"
      ])

    time_in_seconds
    |> IO.inspect()
    |> String.trim()
    |> String.to_float()
    |> ceil()
  end
end
