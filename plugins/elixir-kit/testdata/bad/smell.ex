# Intentional smells for elixir-rg-gate discrimination (not product code).
defmodule Smell do
  def atom_bad(raw), do: String.to_atom(raw)

  def sql_bad(id) do
    q = "SELECT * FROM users WHERE id = #{id}"
    q
  end

  def sleep_bad do
    Process.sleep(1000)
    :ok
  end
end
