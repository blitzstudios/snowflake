defmodule Snowflake.Utils do
  @moduledoc """
  Utility functions intended for Snowflake application.
  epoch() and machine_id() are useful for inspecting in production.
  """

  @doc """
  Grabs epoch from config value
  """
  @spec epoch() :: integer
  def epoch() do
    Application.get_env(:snowflake, :epoch)
  end

  @doc """
  Grabs hostname, fqdn, and ip addresses, then compares that list to the nodes
  config to find the intersection.
  """
  @spec machine_id() :: integer
  def machine_id() do
    nodes = Application.get_env(:snowflake, :nodes)
    host_addrs = [hostname(), fqdn()] ++ ip_addrs()

    case MapSet.intersection(MapSet.new(host_addrs), MapSet.new(nodes)) |> Enum.take(1) do
      [matching_node] -> Enum.find_index(nodes, fn node -> node == matching_node end)
      _ -> 1023
    end
  end

  defp ip_addrs() do
    case :inet.getifaddrs do
      {:ok, ifaddrs} ->
        ifaddrs
        |> Enum.flat_map(fn {_, kwlist} ->
          kwlist |> Enum.filter(fn {type, _} -> type == :addr end)
        end)
        |> Enum.filter_map(fn {_, addr} -> tuple_size(addr) in [4, 6] end, fn {_, addr} ->
          case addr do
            {a, b, c, d} -> [a, b, c, d] |> Enum.join(".")              # ipv4
            {a, b, c, d, e, f} -> [a, b, c, d, e, f] |> Enum.join(":")  # ipv6
          end
        end)
      _ -> []
    end
  end

  defp hostname() do
    {:ok, name} = :inet.gethostname()
    to_string(name)
  end

  defp fqdn() do
    case :inet.get_rc[:domain] do
      nil -> nil
      domain -> hostname() <> "." <> to_string(domain)
    end
  end
end
