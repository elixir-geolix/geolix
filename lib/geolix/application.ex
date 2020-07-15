defmodule Geolix.Application do
  @moduledoc false

  use Application

  @doc false
  def start(_type, _args), do: Geolix.Supervisor.start_link([])
end
