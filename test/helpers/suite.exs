defmodule Geolix.TestHelper.Suite do
  defmacro __using__(_) do
    quote do
      setup do
        { :ok, _ } = Geolix.Server.start_link([])

        on_exit fn ->
          :ok = Geolix.Server.stop()
        end

        :ok
      end
    end
  end
end
