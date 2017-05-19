defmodule Noteblock.BlockControllerTest do
  use Noteblock.ConnCase

  alias Noteblock.{Repo, Block, Hash}

  @valid_block_attrs %{
    data: %{"number" => "2", "note" => "hello jupiter", "action" => "create"}
  }

  @invalid_attrs %{
    data: %{
      "number" => "",
      "action" => ""
    }
  }

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, block_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing blocks"
  end

  test "index displays a button for verifying the ledger", %{conn: conn} do
    conn = get conn, block_path(conn, :index)
    assert html_response(conn, 200) =~ "Verify Ledger"
  end

  test "ledgers can be verified", %{conn: conn} do
    conn = get conn, block_path(conn, :verify_ledger)
    assert html_response(conn, 200) =~ "Ledger Status: verified"
  end

  test "renders form for new resources", %{conn: conn} do
    Repo.insert! %Block{
      originating_block: Hash.sha256("faker"),
      previous_hash: Hash.sha256("other faker")
    }

    conn = get conn, block_path(conn, :new)
    assert html_response(conn, 200) =~ "New block"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    Repo.insert! %Block{
      data: %{"number" => "1", "note" => "hwllo eorld"},
      originating_block: Hash.sha256("faker"),
      hash: Hash.sha256("faker"),
      previous_hash: Hash.sha256("other faker")
    }

    conn = post conn, block_path(conn, :create), block: @valid_block_attrs
    assert redirected_to(conn) == block_path(conn, :index)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    Repo.insert! %Block{
      data: %{"number" => "1", "note" => "hwllo eorld", "action" => "create"},
      originating_block: Hash.sha256("faker"),
      hash: Hash.sha256("faker"),
      previous_hash: Hash.sha256("other faker")
    }

    conn = post conn, block_path(conn, :create), block: @invalid_attrs
    assert html_response(conn, 200) =~ "New block"
  end

  test "shows chosen resource", %{conn: conn} do
    block_1 = Repo.insert! %Block{
      data: %{"number" => "1", "note" => "hwllo eorld", "action" => "create"},
      originating_block: Hash.sha256("1"),
      hash: Hash.sha256("1"),
      previous_hash: Hash.sha256("0")
    }

    block_2 = Repo.insert! %Block{
      data: %{"number" => "1", "note" => "hello world", "action" => "update"},
      originating_block: Hash.sha256("1"),
      hash: Hash.sha256("2"),
      previous_hash: Hash.sha256("1")
    }

    block_3 = Repo.insert! %Block{
      data: %{"number" => "1", "note" => "Hello, World!", "action" => "update"},
      originating_block: Hash.sha256("1"),
      hash: Hash.sha256("3"),
      previous_hash: Hash.sha256("2")
    }

    conn = get conn, block_path(conn, :show, block_3.hash)
    response = html_response(conn, 200)

    assert response =~ "Note 1"
    assert response =~ block_1.data["note"]
    assert response =~ block_2.data["note"]
    assert response =~ block_3.data["note"]
  end

  test "renders form to edit a chosen resource", %{conn: conn} do
    block = Repo.insert! %Block{
      data: %{"number" => "1", "note" => "hwllo eorld"},
      hash: Hash.sha256("faker"),
      originating_block: Hash.sha256("faker"),
      previous_hash: Hash.sha256("other faker")
    }

    conn = get conn, block_path(conn, :edit, block.hash)
    response = html_response(conn, 200)

    assert response =~ "hwllo eorld"
    assert response =~ Hash.sha256("faker")
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    block = Repo.insert! %Block{
      data: %{"number" => "1", "note" => "hwllo eorld"},
      hash: Hash.sha256("faker"),
      originating_block: Hash.sha256("faker"),
      previous_hash: Hash.sha256("other faker")
    }

    updates = %{
      data: %{number: 1, note: "hello world"}
    }

    conn = put conn, block_path(conn, :update, block.hash), block: updates
    assert redirected_to(conn) == block_path(conn, :index)
  end

  test "deletes a resource", %{conn: conn} do
    block = Repo.insert! %Block{
      data: %{"number" => "1", "note" => "hwllo eorld"},
      originating_block: Hash.sha256("faker"),
      hash: Hash.sha256("faker"),
      previous_hash: Hash.sha256("previous faker")
    }

    conn = delete conn, block_path(conn, :delete, block.hash)
    assert redirected_to(conn) == block_path(conn, :index)
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, block_path(conn, :show, -1)
    end
  end
end
