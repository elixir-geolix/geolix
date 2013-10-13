defmodule Geolix do
  use Supervisor.Behaviour

  def start_link(data_path) do
    :supervisor.start_link(__MODULE__, data_path)
  end

  def init(data_path) do
    children = [ worker(Geolix.Server, [data_path]) ]

    supervise(children, strategy: :one_for_one)
  end
end
