defmodule ChirpCockroach.Files do
  def persist_tmp_file(source, name) do
    destination = Path.join([:code.priv_dir(:chirp_cockroach), "static", "tmp", name])
    File.cp!(source, destination)

    {:ok, destination}
  end

  def delete_tmp_file(name) do
    path = Path.join([:code.priv_dir(:chirp_cockroach), "static", "tmp", name])
    File.rm!(path)
  end
end
