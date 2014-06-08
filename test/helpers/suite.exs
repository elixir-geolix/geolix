defmodule Geolix.TestHelper.Suite do
  defmacro __using__(_) do
    quote do
      setup_all do
        { :ok, _ } = Geolix.Server.start_link([])
        :ok
      end

      teardown_all do
        :ok = Geolix.Server.stop()
      end
    end
  end
end
