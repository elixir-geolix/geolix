defmodule Geolix.Adapter.Decoder do
  @moduledoc """
  Behaviour definition for decoder modules.
  """

  @type decoded :: atom | binary | boolean | list | map

  @doc """
  Decodes the datatype found at the given offset of the data.
  """
  @callback decode(data :: binary,
                   data_part :: binary) :: { value :: decoded,
                                             rest  :: binary }
  @doc """
  Decodes the node at the given offset.
  """
  @callback value(data :: binary, offset :: non_neg_integer) :: decoded
end
