# Good fixture: to_existing_atom, parameterized query, documented allow.
defmodule Ok do
  def atom_ok(raw), do: String.to_existing_atom(raw)

  def sql_ok(repo, id), do: repo.query("SELECT id FROM users WHERE id = $1", [id])

  # Documented intentional seam (boot probe); keep allow on the smell line.
  def documented_legacy(raw), do: String.to_atom(raw) # elixir-rg-allow: fixture documents allow marker for intentional atom seam
end
