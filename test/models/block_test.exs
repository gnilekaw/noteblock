defmodule Noteblock.BlockTest do
  use Noteblock.ModelCase

  alias Noteblock.Block

  @valid_attrs %{
    hash: "the hash",
    previous_hash: "the hash before this one",
    originating_block: "the hash, or, another hash",
    data: %{
      "number" => "1000000",
      "action" => "create"
    }
  }

  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Block.changeset(%Block{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Block.changeset(%Block{}, @invalid_attrs)
    refute changeset.valid?
  end
end
