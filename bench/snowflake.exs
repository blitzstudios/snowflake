Application.ensure_all_started(:snowflake)

# To test against snowflakex, uncomment the second line in the benchmark
# and also add snowflakex as a dependency to your mix.exs

Benchee.run(%{
  "snowflake" => fn -> Snowflake.next_id() end,
  # "snowflakex" => fn -> Snowflakex.new() end
})
