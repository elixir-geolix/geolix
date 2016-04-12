defmodule Geolix.Adapter.MMDB2.Metadata do
  @moduledoc """
  Metadata struct.
  """

  @type t :: %__MODULE__{
    binary_format_major_version: integer,
    binary_format_minor_version: integer,
    build_epoch:                 integer,
    database_type:               String.t,
    description:                 map,
    ip_version:                  integer,
    languages:                   List.t,
    node_byte_size:              integer,
    node_count:                  integer,
    record_size:                 integer,
    tree_size:                   integer
  }

  defstruct [
    binary_format_major_version: 0,
    binary_format_minor_version: 0,
    build_epoch:                 0,
    database_type:               "",
    description:                 %{},
    ip_version:                  0,
    languages:                   [],
    node_byte_size:              0,
    node_count:                  0,
    record_size:                 0,
    tree_size:                   0
  ]
end
