defmodule Snowflake do
  @moduledoc """
  Generates Snowflake IDs
  """
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      worker(Snowflake.Generator, [Snowflake.Utils.epoch(), Snowflake.Utils.machine_id()])
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end

  @doc """
  Generates a snowflake ID, each call is guaranteed to return a different ID
  that is sequantially larger than the previous ID.
  """
  @spec next_id() :: {:ok, integer} |
                     {:error, :backwards_clock}
  def next_id() do
    GenServer.call(Snowflake.Generator, :next_id)
  end
end
