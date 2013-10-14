defmodule Geolix do
  use Supervisor.Behaviour

  def start_link(db_dir) when is_binary(db_dir) do
    if File.dir?(db_dir) do
      unless String.ends_with?(db_dir, "/") do
        db_dir = db_dir <> "/"
      end

      :supervisor.start_link(__MODULE__, db_dir)
    else
      { :error, "Given directory '#{db_dir}' is not a path?!" }
    end
  end

  def start_link(_) do
    { :error, "Please provide a database directory! (as binary string)" }
  end

  def init(db_dir) do
    children = [ worker(Geolix.Server, [db_dir]) ]

    supervise(children, strategy: :one_for_one)
  end
end
