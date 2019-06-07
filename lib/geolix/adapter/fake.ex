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
      ...>     {127, 0, 0, 1} => "IPv4",
      ...>     {0, 0, 0, 0, 0, 0, 0, 1} => "IPv6"
      ...>   }
      ...> })
      :ok
      iex> Geolix.lookup("127.0.0.1", where: :fake_sample)
      "IPv4"
      iex> Geolix.lookup("::1", where: :fake_sample)
      "IPv6"
      iex> Geolix.lookup("255.255.255.255", where: :fake_sample)
      nil

  The lookup is done by exactly matching the IP address tuple received
  and will return the predefined result as is.
  """

  alias Geolix.Adapter.Fake.Storage

  @behaviour Geolix.Adapter

  @impl Geolix.Adapter
  def database_workers do
    import Supervisor.Spec

    [worker(Storage, [])]
  end

  @impl Geolix.Adapter
  def load_database(%{data: data, id: id}), do: Storage.set(id, data)

  @impl Geolix.Adapter
  def lookup(ip, opts) do
    opts
    |> Keyword.fetch!(:where)
    |> Storage.get()
    |> Map.get(ip, nil)
  end

  @impl Geolix.Adapter
  def unload_database(%{id: id}), do: Storage.set(id, nil)
end
