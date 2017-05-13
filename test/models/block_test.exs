defmodule Noteblock.BlockTest do
  use Noteblock.ModelCase

  alias Noteblock.Block

  @valid_attrs %{
    data: %{},
    hash: "some content",
    originating_block: "some content",
    previous_hash: "some content"
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
