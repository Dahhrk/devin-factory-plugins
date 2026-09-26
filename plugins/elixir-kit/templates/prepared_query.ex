# Named boundary: prefer parameterized Ecto / Repo.query over SQL string concat or #{} interpolation.
# Copy into product sources; keep elixir-rg-allow only on intentional seams.

defmodule Factory.PreparedQuery do
  @moduledoc false

  # Example signature only — wire to your Repo.
  @spec fetch_user(module(), integer()) :: {:ok, map()} | {:error, term()}
  def fetch_user(repo, id) when is_integer(id) do
    case repo.query("SELECT id, email FROM users WHERE id = $1", [id]) do
      {:ok, %{rows: [row]}} -> {:ok, row}
      {:ok, %{rows: []}} -> {:error, :not_found}
      {:error, reason} -> {:error, reason}
    end
  end
end
