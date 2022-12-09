defmodule Snowflake.Generator do
  @moduledoc false
  use GenServer

  @machine_id_overflow 1024
  @seq_overflow 4096

  def start_link([epoch, machine_id]) when machine_id < @machine_id_overflow do
    state = {epoch, ts(epoch), machine_id, 0}
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(args) do
    {:ok, args}
  end

  def handle_call(:next_id, from, {epoch, prev_ts, machine_id, seq} = state) do
    case next_ts_and_seq(epoch, prev_ts, seq) do
      {:error, :seq_overflow} ->
        :timer.sleep(1)
        handle_call(:next_id, from, state)
      {:error, :backwards_clock} ->
        {:reply, {:error, :backwards_clock}, state}
      {:ok, new_ts, new_seq} ->
        new_state = {epoch, new_ts, machine_id, new_seq}
        {:reply, {:ok, create_id(new_ts, machine_id, new_seq)}, new_state}
    end
  end

  def handle_call(:machine_id, _from, {_epoch, _prev_ts, machine_id, _seq} = state) do
    {:reply, {:ok, machine_id}, state}
  end

  def handle_call({:set_machine_id, machine_id}, _from, {epoch, prev_ts, _old_machine_id, seq}) do
    {:reply, {:ok, machine_id}, {epoch, prev_ts, machine_id, seq}}
  end

  defp next_ts_and_seq(epoch, prev_ts, seq) do
    case ts(epoch) do
      ^prev_ts ->
        case seq + 1 do
          @seq_overflow -> {:error, :seq_overflow}
          next_seq -> {:ok, prev_ts, next_seq}
        end
      new_ts ->
        cond do
          new_ts < prev_ts -> {:error, :backwards_clock}
          true -> {:ok, new_ts, 0}
        end
    end
  end

  defp create_id(ts, machine_id, seq) do
    << new_id :: unsigned-integer-size(64)>> = <<
       ts :: unsigned-integer-size(42),
       machine_id :: unsigned-integer-size(10),
       seq :: unsigned-integer-size(12) >>

    new_id
  end

  defp ts(epoch) do
    System.os_time(:millisecond) - epoch
  end
end
