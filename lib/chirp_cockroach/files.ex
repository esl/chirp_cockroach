defmodule ChirpCockroach.Files do
  def persist_tmp_file(source, name) do
    destination = Path.join([:code.priv_dir(:chirp_cockroach), "static", "tmp", name])
    File.cp!(source, destination)

    {:ok, destination}
  end

  def persist_file(source, name) do
    destination = Path.join([:code.priv_dir(:chirp_cockroach), "static", "tmp", name])
    File.cp!(source, destination)

    {:ok, %{src: destination, path: "/tmp/#{name}"}}
  end

  def persist_audio_file(source, name) do
    destination = Path.join([:code.priv_dir(:chirp_cockroach), "static", "tmp", name])
    args = ~w(-i #{source} -vn codec:a libmp3lame -b:a 320k -ar 48000 #{destination})
    {data, 0} = System.cmd("ffmpeg", args)

    {:ok, %{src: destination, path: "/tmp/#{name}"}}
  end

  def file_source(path) do
    {:file, Path.join([:code.priv_dir(:chirp_cockroach), "static", path])}
  end

  def delete_tmp_file(name) do
    path = Path.join([:code.priv_dir(:chirp_cockroach), "tmp", name])
    File.rm!(path)
  end
end
