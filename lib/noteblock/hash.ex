defmodule Noteblock.Hash do
  @doc """
    Creates a sha256 hash.

    ## Examples

        iex> Noteblock.Hash.sha256({:ok, "Foo"})
        "1CBEC737F863E4922CEE63CC2EBBFAAFCD1CFF8B790D8CFD2E6A5D550B648AFA"

        iex> Noteblock.Hash.sha256("Bar")
        "95D64CACCE0F0E5B0D1B843862F0ACCFADB787A4CABB8A88F7F1694EA232A5FC"

  """
  def sha256({:ok, string}), do: sha256(string)

  def sha256(string) do
    :crypto.hash(:sha256, string) |> Base.encode16
  end

  @doc """
    Creates a shasum from a JSON-encoded block.
  """
  def new(%{previous_hash: p, data: d}) do
    empty_value = [p, d] |> Enum.any?(&is_nil/1)

    if empty_value do
      {:error, "Nil keys are not allowed"}
    else
      shasum = [p, d] |> Poison.encode |> sha256

      {:ok, shasum}
    end
  end

  def verify(block_1, block_2) do
    previous_hash_matches = block_1.previous_hash == block_2.hash

    {:ok, block_1_hash} = new(%{
      previous_hash: block_1.previous_hash,
      data: block_1.data
    })

    current_hash_matches = block_1.hash == block_1_hash

    (previous_hash_matches && current_hash_matches)
  end
end
