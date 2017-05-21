defmodule Noteblock.HashTest do
  use ExUnit.Case, async: true

  doctest Noteblock.Hash

  alias Noteblock.Hash
  alias Noteblock.Transaction

  test "Hash.new creates a new hash with correct values" do
    transaction = %{
      data: %{number: 1, note: "Foo"},
      previous_hash: "fake hash"
    }

    expected = {
      :ok,
      "AA898DBE558D35DA696E12C3E708158D96DB09A46E3604542E01A7E0AFB292FE"
    }

    assert Hash.new(transaction) == expected
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
    transaction_2_hash = "Foohash"

    transaction_2 = %Transaction{
      hash: transaction_2_hash
    }

    data = "Heap'o JSON"

    {:ok, hash} = Hash.new(%{
      previous_hash: transaction_2_hash,
      data: data
    })

    transaction_1 = %Transaction{
      hash: hash,
      data: data,
      previous_hash: transaction_2_hash
    }

    assert Hash.verify(transaction_1, transaction_2) == true
  end

  test "Hash.verify/2 fails to verify two hashes" do
    transaction_2 = %Transaction{
      hash: "Foohash"
    }

    transaction_1 = %Transaction{
      hash: "Other hash",
      data: "Other data",
      previous_hash: "Other Other hash"
    }

    message = {:error, "Message: The hashes were wrong, but why?"}

    assert Hash.verify(transaction_1, transaction_2) == message
  end

end
