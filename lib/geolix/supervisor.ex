defmodule Geolix.Supervisor do
  @moduledoc """
  Geolix Supervisor.
  """

  use Supervisor

  alias Geolix.Database
  alias Geolix.Server.Pool


  @doc """
  Starts the supervisor.
  """
  @spec start_link(term) :: Supervisor.on_start
  def start_link(default \\ []) do
    Supervisor.start_link(__MODULE__, default)
  end

  @doc false
  def init(_default) do
    children = [
      Pool.child_spec,
      supervisor(Database.Supervisor, [])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
