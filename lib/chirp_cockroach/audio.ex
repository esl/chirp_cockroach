defmodule ChirpCockroach.Audio do
  def whisper(path, func \\ &print/2, chunk_time \\ 20) do
    duration = audio_duration(path)
    0..duration//chunk_time
    |> Task.async_stream(
      fn ss ->
        {_, data} = convert_audio(path, ss, chunk_time)
        {ss, whisperify(data)}
      end,
    max_concurrency: 4,
    timeout: :infinity
    )
    |> Enum.map(fn {:ok, {ss, %{chunks: [%{text: text}]}}} -> func.(ss, text) end)
  end

  def print(ss, text) do
    IO.puts("#{ss}: #{text}")
  end

  def whisperify(input) do
    {:ok, %{serving: serving}} = ChirpCockroach.Audio.Whisper.get()

    Nx.Serving.run(serving, input)
  end

  def convert_audio(path, ss, chunk_time) do
    args = ~w(-ac 1 -ar 16k -f f32le -ss #{ss} -t #{chunk_time} -v quiet -)
    {data, 0} = System.cmd("ffmpeg", ["-i", path] ++ args)

    {ss, Nx.from_binary(data, :f32)}
  end

  def audio_duration(path) do
    {time_in_seconds, _error} = System.cmd("ffprobe", [
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
    |> String.trim()
    |> String.to_float()
    |> ceil()
  end

end

# {0, data} = ChirpCockroach.Audio.convert_audio("./sample.mp3", 0, 100)
# input = Nx.from_binary(data, :f32)
# ChirpCockroach.Audio.whisperify(input)
