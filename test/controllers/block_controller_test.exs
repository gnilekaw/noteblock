defmodule Noteblock.BlockControllerTest do
  use Noteblock.ConnCase

  alias Noteblock.{Repo, Block, Hash}

  @valid_block_attrs %{
    hash: "some hash",
    previous_hash: "some other hash",
    originating_block: "some hash"
  }

  @valid_data_attrs %{
    data: %{number: 1, note: "hello jupiter"}
  }

  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, block_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing blocks"
  end

  test "renders form for new resources", %{conn: conn} do
    Repo.insert! %Block{
      data: %{number: 1, note: "hwllo eorld"},
      hash: Hash.sha256("faker"),
      originating_block: Hash.sha256("faker"),
      previous_hash: Hash.sha256("other faker")
    }

    conn = get conn, block_path(conn, :new)
    assert html_response(conn, 200) =~ "New block"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, block_path(conn, :create), block: @valid_block_attrs, data: @valid_data_attrs
    assert redirected_to(conn) == block_path(conn, :index)
    assert Repo.get_by(Block, @valid_block_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, block_path(conn, :create), block: @invalid_attrs, data: @invalid_attrs
    assert html_response(conn, 200) =~ "New block"
  end

  test "shows chosen resource", %{conn: conn} do
    block = Repo.insert! %Block{
      data: %{number: 1, note: "hwllo eorld"},
      originating_block: Hash.sha256("faker"),
      hash: Hash.sha256("faker"),
      previous_hash: Hash.sha256("other faker")
    }

    conn = get conn, block_path(conn, :show, block.hash)
    assert html_response(conn, 200) =~ "Note 1"
  end

  test "renders form to edit a resources", %{conn: conn} do
    block = Repo.insert! %Block{
      data: %{number: 1, note: "hwllo eorld"},
      hash: Hash.sha256("faker"),
      originating_block: Hash.sha256("faker"),
      previous_hash: Hash.sha256("other faker")
    }

    conn = get conn, block_path(conn, :edit, block.hash)
    response = html_response(conn, 200)

    assert response =~ "hwllo eorld"
    assert response =~ Hash.sha256("faker")
  end

  test "deletes a resource", %{conn: conn} do
    block = Repo.insert! %Block{
      data: %{number: 1, note: "hwllo eorld"},
      originating_block: Hash.sha256("faker"),
      hash: Hash.sha256("faker"),
      previous_hash: Hash.sha256("previous faker")
    }

    conn = delete conn, block_path(conn, :delete, block.hash)
    assert redirected_to(conn) == block_path(conn, :index)

    # TODO: Test that the new block show that it is deleted
    # assert Map.get(new_block_data, :number) == nil
    # assert Map.get(new_block_data, :note) == nil
    # assert Map.get(new_block_data, :action) == "delete"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, block_path(conn, :show, -1)
    end
  end
end
