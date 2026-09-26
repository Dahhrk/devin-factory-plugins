# Named boundary: prefer String.to_existing_atom / allowlisted atoms over String.to_atom on input.
# Copy into product sources; keep elixir-rg-allow only on intentional seams.

defmodule Factory.SafeAtom do
  @moduledoc false

  @allowed %{
    "active" => :active,
    "archived" => :archived
  }

  @spec from_input(String.t()) :: {:ok, atom()} | {:error, :unknown_atom}
  def from_input(raw) when is_binary(raw) do
    case Map.fetch(@allowed, raw) do
      {:ok, atom} -> {:ok, atom}
      :error ->
        try do
          {:ok, String.to_existing_atom(raw)}
        rescue
          ArgumentError -> {:error, :unknown_atom}
        end
    end
  end
end
