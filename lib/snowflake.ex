defmodule Snowflake do
  @moduledoc """
  Generates Snowflake IDs
  """
  use Application

  def start(_type, _args) do
    children = [
      {Snowflake.Generator, [Snowflake.Helper.epoch(), Snowflake.Helper.machine_id()]}
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

  @doc """
  Returns the machine id of the current node.
  """
  @spec machine_id() :: {:ok, integer}
  def machine_id() do
    GenServer.call(Snowflake.Generator, :machine_id)
  end

  @doc """
  Returns the machine id of the current node.
  """
  @spec set_machine_id(integer) :: {:ok, integer}
  def set_machine_id(machine_id) do
    GenServer.call(Snowflake.Generator, {:set_machine_id, machine_id})
  end
end
