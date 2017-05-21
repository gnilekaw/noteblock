defmodule Noteblock.TransactionTest do
  use Noteblock.ModelCase

  alias Noteblock.Transaction

  @valid_attrs %{
    hash: "the hash",
    previous_hash: "the hash before this one",
    originating_hash: "the hash, or, another hash",
    data: %{
      "number" => "1000000",
      "action" => "create"
    }
  }

  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Transaction.changeset(%Transaction{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Transaction.changeset(%Transaction{}, @invalid_attrs)
    refute changeset.valid?
  end
end
