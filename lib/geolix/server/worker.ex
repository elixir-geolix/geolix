defmodule Geolix.Server.Worker do
  @moduledoc """
  Worker module reading a database and looking up IP information.
  """

  alias Geolix.Adapter.MMDB2
  alias Geolix.Database.Loader

  use GenServer


  @behaviour :poolboy_worker

  def start_link(default \\ %{}) do
    GenServer.start_link(__MODULE__, default)
  end

  def handle_call({ :lookup, ip, opts }, _, state) do
    case opts[:where] do
      nil    -> { :reply, lookup_all(ip, opts),    state }
      _where -> { :reply, lookup_single(ip, opts), state }
    end
  end


  defp lookup_all(ip, opts) do
    databases = GenServer.call(Loader, :registered)

    lookup_all(ip, opts, databases)
  end

  defp lookup_all(_,  _,    []),       do: %{}
  defp lookup_all(ip, opts, databases) do
    databases
    |> Enum.map(fn (database) ->
	 task_opts = Keyword.put(opts, :where, database)

         { database, Task.async(fn -> lookup_single(ip, task_opts) end) }
       end)
    |> Enum.map(fn ({ database, task }) -> { database, Task.await(task) } end)
    |> Enum.into(%{})
  end

  defp lookup_single(ip, opts) do
    database = GenServer.call(Loader, { :get_database, opts[:where] })

    case database do
      nil   -> nil
      _info -> MMDB2.lookup(ip, opts)
    end
  end
end
