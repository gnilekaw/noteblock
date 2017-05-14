defmodule Noteblock.HashTest do
  use ExUnit.Case, async: true

  doctest Noteblock.Hash

  alias Noteblock.Hash

  test "Hash.new creates a new hash with correct values" do
    block = %{
      data: %{number: 1, note: "Foo"},
      originating_block: "fake hash",
      previous_hash: "fake hash"
    }

    expected = {
      :ok,
      "20BBE4EAA577D591755DDD460258F001DED9226C3E22EBF9111285B77241FA00"
    }

    assert Hash.new(block) == expected
  end

  test "Hash.new returns an error when any values are nil" do
    map = %{
      data: nil,
      originating_block: nil,
      previous_hash: nil
    }

    expected = {:error, "Nil keys are not allowed"}

    assert Hash.new(map) == expected
  end
end
