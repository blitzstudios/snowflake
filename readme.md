# Snowflake

A distributed Snowflake generator in Elixir.

## Usage

In your mix.exs file:

```elixir
def deps do
  [{:snowflake, "~> 0.0.1"}]
end
```

Specify the nodes in your config.  If your running a cluster, specify all the nodes in the cluster that snowflake runs on.  

- **nodes** can be Public IPs, Private IPs, Hostnames, or FQDNs
- **epoch** should not be changed once you begin generating IDs and want to maintain sorting
- There should be no more than 1 snowflake generator per node, or you risk duplicate potential duplicate snowflakes on the same node.

```elixir
config :snowflake,
  nodes: [127.0.0.1],   # up to 1023 nodes
  epoch: 1142974214000  # don't change after you decide what your epoch is
```

Generating an ID is simple.

```elixir
Snowflake.next_id()
# => 828746161129414660
```

## Helper functions

After generating snowflake IDs, you may want to use them to do other things.
For example, deriving a bucket number from a snowflake to use as part of a
composite key in Cassandra in the attempt to limit partition size.

Lets say we want to know the current bucket for an ID that would be generated right now:
```elixir
Snowflake.Helper.bucket(30, :days)
# => 5
```

Or if we want to know which bucket a snowflake ID should belong to, given we are
bucketing by every 30 days.
```elixir
Snowflake.Helper.bucket(30, :days, 828746161129414661)
# => 76
```

Or if we want to know how many ms elapsed from epoch
```elixir
Snowflake.Helper.timestamp_of_id(828746161129414661)
# => 197588482172
```

## NTP

Keep your nodes in sync with [ntpd](https://en.wikipedia.org/wiki/Ntpd) or use
your VM equivalent as snowflake depends on OS time.  ntpd's job is to slow down
or speed up the clock so that it syncs the time with the network time.

## Architecture

Snowflake allows the user to specify the nodes in the cluster, each representing a machine.  Snowflake at startup inspects itself for IP and Host information and derives its machine_id from the location of itself in the list of nodes defined in the config.

Machine ID is defaulted to **1023** if there is no configuration or if snowflake does not find a match to remain highly available.  It is important to specify the correct IPs / Hostnames / FQDNs for the nodes in a production environment to avoid any chance of snowflake collision.

## Benchmarks

Consistently generates over 60,000 snowflakes per second on Macbook Pro 2.5 GHz Intel Core i7 w/ 16 GB RAM.

```
Benchmarking snowflake...
Benchmarking snowflakex...

Name                 ips        average  deviation         median
snowflake       316.51 K        3.16 μs   ±503.52%        3.00 μs
snowflakex      296.26 K        3.38 μs   ±514.60%        3.00 μs

Comparison:
snowflake       316.51 K
snowflakex      296.26 K - 1.07x slower
```
