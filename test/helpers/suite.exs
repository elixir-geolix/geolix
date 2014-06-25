defmodule Geolix.TestHelper.Suite do
  defmacro __using__(_) do
    quote do
      setup do
        { :ok, pid } = Geolix.Server.start_link([])

        on_exit fn ->
          if Process.alive?(pid) do
            Process.exit(pid, :kill)
          end
        end

        :ok
      end
    end
  end
end
