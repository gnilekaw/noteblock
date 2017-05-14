defmodule Noteblock.HashTest do
  use ExUnit.Case, async: true

  doctest Noteblock.Hash

  alias Noteblock.Hash

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
end
