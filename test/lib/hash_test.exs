defmodule Noteblock.HashTest do
  use ExUnit.Case, async: true

  doctest Noteblock.Hash

  alias Noteblock.Hash
  alias Noteblock.Block

  test "Hash.new creates a new hash with correct values" do
    block = %{
      data: %{number: 1, note: "Foo"},
      previous_hash: "fake hash"
    }

    expected = {
      :ok,
      "AA898DBE558D35DA696E12C3E708158D96DB09A46E3604542E01A7E0AFB292FE"
    }

    assert Hash.new(block) == expected
  end

  test "Hash.new returns an error when any values are nil" do
    map = %{
      data: nil,
      previous_hash: nil
    }

    expected = {:error, "Nil keys are not allowed"}

    assert Hash.new(map) == expected
  end

  test "Hash.verify/2 verifies two hashes" do
    block_2_hash = "Foohash"

    block_2 = %Block{
      hash: block_2_hash
    }

    data = "Heap'o JSON"

    hash = Hash.new(%{
      previous_hash: block_2_hash,
      data: data
    })

    block_1 = %Block{
      hash: hash,
      data: data,
      previous_hash: block_2_hash
    }

    assert Hash.verify(block_1, block_2) == true
  end

  test "Hash.verify/2 fails to verify two hashes" do
    block_2 = %Block{
      hash: "Foohash"
    }

    block_1 = %Block{
      hash: "Other hash",
      data: "Other data",
      previous_hash: "Other Other hash"
    }

    message = {:error, "Message: The hashes were wrong, but why?"}

    assert Hash.verify(block_1, block_2) == message
  end

end
