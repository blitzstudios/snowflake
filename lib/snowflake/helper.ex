defmodule Snowflake.Helper do
  @moduledoc """
  Utility functions intended for Snowflake application.
  epoch() and machine_id() are useful for inspecting in production.
  """
  @default_config [
    nodes: [],
    epoch: 0
  ]

  @doc """
  Grabs epoch from config value
  """
  @spec epoch() :: integer
  def epoch() do
    Application.get_env(:snowflake, :epoch) || @default_config[:epoch]
  end

  @doc """
  Grabs hostname, fqdn, and ip addresses, then compares that list to the nodes
  config to find the intersection.
  """
  @spec machine_id() :: integer
  def machine_id() do
    id = Application.get_env(:snowflake, :machine_id)
    machine_id(id)
  end

  defp machine_id(nil) do
    nodes = Application.get_env(:snowflake, :nodes) || @default_config[:nodes]
    host_addrs = [hostname(), fqdn(), Node.self()] ++ ip_addrs()

    case MapSet.intersection(MapSet.new(host_addrs), MapSet.new(nodes)) |> Enum.take(1) do
      [matching_node] -> Enum.find_index(nodes, fn node -> node == matching_node end)
      _ -> 1023
    end
  end

  defp machine_id(id) when id >= 0 and id < 1024, do: id
  defp machine_id(_id), do: machine_id(nil)

  defp ip_addrs() do
    case :inet.getifaddrs() do
      {:ok, ifaddrs} ->
        ifaddrs
        |> Enum.flat_map(fn {_, kwlist} ->
          kwlist |> Enum.filter(fn {type, _} -> type == :addr end)
        end)
        |> Enum.filter(&(tuple_size(elem(&1, 1)) in [4, 6]))
        |> Enum.map(fn {_, addr} ->
          case addr do
            # ipv4
            {a, b, c, d} -> [a, b, c, d] |> Enum.join(".")
            # ipv6
            {a, b, c, d, e, f} -> [a, b, c, d, e, f] |> Enum.join(":")
          end
        end)

      _ ->
        []
    end
  end

  defp hostname() do
    {:ok, name} = :inet.gethostname()
    to_string(name)
  end

  defp fqdn() do
    case :inet.get_rc()[:domain] do
      nil -> nil
      domain -> hostname() <> "." <> to_string(domain)
    end
  end
end
