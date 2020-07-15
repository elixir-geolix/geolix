defmodule Geolix.Supervisor do
  @moduledoc """
  This supervisor module takes care of starting the required database adapter
  processes. It is automatically started with the `:geolix` application.

  If you do not want to automatically start the application itself you can
  adapt your configuration for a manual supervision approach by adding it
  to your `:included_applications`:

      def application do
        [
          included_applications: [
            # ...
            :geolix,
            # ...
          ]
        ]
      end

  That done you can add `Geolix.Supervisor` to your supervision hierarchy:

      children = [
        # ...
        Geolix.Supervisor,
        # ...
      ]
  """

  use Supervisor

  @doc false
  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @doc false
  def init(_) do
    :ok =
      case Application.get_env(:geolix, :init) do
        {mod, fun, args} -> apply(mod, fun, args)
        {mod, fun} -> apply(mod, fun, [])
        nil -> :ok
      end

    children = [
      Geolix.Database.Supervisor,
      Geolix.Database.Loader
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end
end
