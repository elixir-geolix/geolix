defmodule Geolix.Adapter.Fake do
  @moduledoc """
  Fake adapter for testing environments.

  ## Usage

  This adapter is intended to be used only with static data you can provide
  when the adapter is started, i.e. when performing unit tests.

      iex> Geolix.load_database(%{
      ...>   id: :fake_sample,
      ...>   adapter: Geolix.Adapter.Fake,
      ...>   data: %{
      ...>     {127, 0, 0, 1} => %{"type" => "IPv4"},
      ...>     {0, 0, 0, 0, 0, 0, 0, 1} => %{"type" => "IPv6"}
      ...>   }
      ...> })
      :ok
      iex> Geolix.lookup("127.0.0.1", where: :fake_sample)
      %{"type" => "IPv4"}
      iex> Geolix.lookup("::1", where: :fake_sample)
      %{"type" => "IPv6"}
      iex> Geolix.lookup("255.255.255.255", where: :fake_sample)
      nil

  The lookup is done by exactly matching the IP address tuple received
  and will return the predefined result as is.

  ## Metadata

  The adapter provides access to the time the database was loaded:

      metadata = %{load_epoch: System.os_time(:second)}

  ## Hooks

  To facility testing every callback has a hook available called before the
  callback itself is executed. Every hook can be configured as either
  `{mod, fun}` or `{mod, fun, extra_args}` with the database configuration
  always being passed as the first argument.

  The callback for `lookup/3` (`:mfargs_lookup`) receives the requested `ip`
  as the second parameter before the `extra_args` (if any).

  Available Hooks:

  - `:mfargs_database_workers`
  - `:mfargs_load_database`
  - `:mfargs_lookup`
  - `:mfargs_metadata`
  - `:mfargs_unload_database`
  """

  alias Geolix.Adapter.Fake.Storage

  @behaviour Geolix.Adapter

  @impl Geolix.Adapter
  def database_workers(database) do
    :ok = maybe_apply_mfargs(database, :mfargs_database_workers, [database])

    [{Storage, %{}}]
  end

  @impl Geolix.Adapter
  def load_database(%{data: data, id: id} = database) do
    :ok = maybe_apply_mfargs(database, :mfargs_load_database, [database])
    :ok = Storage.set(id, {data, %{load_epoch: System.os_time(:second)}})
    :ok
  end

  @impl Geolix.Adapter
  def lookup(ip, _opts, %{id: id} = database) do
    :ok = maybe_apply_mfargs(database, :mfargs_lookup, [database, ip])

    id
    |> Storage.get_data()
    |> Map.get(ip, nil)
  end

  @impl Geolix.Adapter
  def metadata(%{id: id} = database) do
    :ok = maybe_apply_mfargs(database, :mfargs_metadata, [database])

    Storage.get_meta(id)
  end

  @impl Geolix.Adapter
  def unload_database(%{id: id} = database) do
    :ok = maybe_apply_mfargs(database, :mfargs_unload_database, [database])
    :ok = Storage.set(id, {nil, nil})
    :ok
  end

  defp maybe_apply_mfargs(database, key, cb_args) do
    _ =
      case Map.get(database, key) do
        {mod, fun, extra_args} -> apply(mod, fun, cb_args ++ extra_args)
        {mod, fun} -> apply(mod, fun, cb_args)
        nil -> :ok
      end

    :ok
  end
end
