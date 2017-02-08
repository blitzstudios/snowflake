defmodule Snowflake.Helper do
  @moduledoc """
  The Helper module helps users work with snowflake IDs.

  Helper module can do the following:
  - Deriving timestamp based on ID
  - Creating buckets based on days since epoch...
  """
  use Bitwise

  @doc """
  Get timestamp in ms from epoch from any snowflake ID
  """
  @spec timestamp_of_id(integer) :: integer
  def timestamp_of_id(id) do
    id >>> 22
  end

  @doc """
  Get bucket value based on segments of N days
  """
  @spec bucket(integer, atom, integer) :: integer
  def bucket(units, unit_type, id) do
    round(timestamp_of_id(id) / bucket_size(unit_type, units))
  end

  @doc """
  When no id is provided, we generate a bucket for the current time
  """
  @spec bucket(integer, atom) :: integer
  def bucket(units, unit_type) do
    timestamp = System.os_time(:milliseconds) - Snowflake.Utils.epoch()
    round(timestamp / bucket_size(unit_type, units))
  end

  defp bucket_size(unit_type, units) do
    case unit_type do
      :hours -> 1000 * 60 * 60 * units
      _ -> 1000 * 60 * 60 * 24 * units  # days is default
    end
  end
end
