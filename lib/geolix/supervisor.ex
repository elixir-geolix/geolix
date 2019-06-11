defmodule Geolix.Supervisor do
  @moduledoc """
  This supervisor module takes care of starting the required database adapter
  processes. It is automatically started with the `:geolix` application.

  If you do not want to automatically start the application itself you can
  adapt your configuration for a more manual supervision approach.

  Instead of adding `:geolix` to your `:applications` list or using the
  automatic discovery you need to add it to your `:included_applications`:

      def application do
        [
          included_applications: [
            # ...
            :geolix,
            # ...
          ]
        ]
      end

  That done you can add `Geolix.Supervisor` to your hierarchy:

      children = [
        # ...
        Geolix.Supervisor,
        # ...
      ]
  """

  use Supervisor

  @doc false
  def start_link(default \\ []) do
    Supervisor.start_link(__MODULE__, default, name: __MODULE__)
  end

  @doc false
  def init(_default) do
    :ok =
      case Application.get_env(:geolix, :init) do
        {mod, fun, args} -> apply(mod, fun, args)
        {mod, fun} -> apply(mod, fun, [])
        nil -> :ok
      end

    children = [
      Geolix.Server.Pool,
      Geolix.Database.Supervisor
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
