defmodule Noteblock.TransactionControllerTest do
  use Noteblock.ConnCase

  alias Noteblock.{Repo, Transaction, Hash}

  @valid_transaction_attrs %{
    data: %{"number" => "2", "note" => "hello jupiter", "action" => "create"}
  }

  @invalid_attrs %{
    data: %{
      "number" => "",
      "action" => ""
    }
  }

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, transaction_path(conn, :index)
    assert html_response(conn, 200) =~ "Ledger"
  end

  test "index displays a button for verifying the ledger", %{conn: conn} do
    conn = get conn, transaction_path(conn, :index)
    assert html_response(conn, 200) =~ "Verify Ledger"
  end

  test "ledgers can be verified", %{conn: conn} do
    Repo.insert! %Transaction{
      originating_hash: Hash.sha256("faker"),
      previous_hash: Hash.sha256("other faker")
    }

    Repo.insert! %Transaction{
      data: %{"number" => "1", "note" => "hwllo eorld"},
      originating_hash: Hash.sha256("faker"),
      hash: Hash.sha256("faker"),
      previous_hash: Hash.sha256("other faker")
    }

    conn = get conn, transaction_path(conn, :verify_ledger)
    # The default state, when there are no transactions existing
    assert html_response(conn, 200) =~ "Ledger Status: Errors"
  end

  test "renders form for new resources", %{conn: conn} do
    Repo.insert! %Transaction{
      originating_hash: Hash.sha256("faker"),
      previous_hash: Hash.sha256("other faker")
    }

    conn = get conn, transaction_path(conn, :new)
    assert html_response(conn, 200) =~ "New transaction"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    Repo.insert! %Transaction{
      data: %{"number" => "1", "note" => "hwllo eorld"},
      originating_hash: Hash.sha256("faker"),
      hash: Hash.sha256("faker"),
      previous_hash: Hash.sha256("other faker")
    }

    conn = post conn, transaction_path(conn, :create), transaction: @valid_transaction_attrs
    assert redirected_to(conn) == transaction_path(conn, :index)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    Repo.insert! %Transaction{
      data: %{"number" => "1", "note" => "hwllo eorld", "action" => "create"},
      originating_hash: Hash.sha256("faker"),
      hash: Hash.sha256("faker"),
      previous_hash: Hash.sha256("other faker")
    }

    conn = post conn, transaction_path(conn, :create), transaction: @invalid_attrs
    assert html_response(conn, 200) =~ "New transaction"
  end

  test "shows chosen resource", %{conn: conn} do
    transaction_1 = Repo.insert! %Transaction{
      data: %{"number" => "1", "note" => "hwllo eorld", "action" => "create"},
      originating_hash: Hash.sha256("1"),
      hash: Hash.sha256("1"),
      previous_hash: Hash.sha256("0")
    }

    transaction_2 = Repo.insert! %Transaction{
      data: %{"number" => "1", "note" => "hello world", "action" => "update"},
      originating_hash: Hash.sha256("1"),
      hash: Hash.sha256("2"),
      previous_hash: Hash.sha256("1")
    }

    transaction_3 = Repo.insert! %Transaction{
      data: %{"number" => "1", "note" => "Hello, World!", "action" => "update"},
      originating_hash: Hash.sha256("1"),
      hash: Hash.sha256("3"),
      previous_hash: Hash.sha256("2")
    }

    conn = get conn, transaction_path(conn, :show, transaction_3.hash)
    response = html_response(conn, 200)

    assert response =~ "Note 1"
    assert response =~ transaction_1.data["note"]
    assert response =~ transaction_2.data["note"]
    assert response =~ transaction_3.data["note"]
  end

  test "renders form to edit a chosen resource", %{conn: conn} do
    transaction = Repo.insert! %Transaction{
      data: %{"number" => "1", "note" => "hwllo eorld"},
      hash: Hash.sha256("faker"),
      originating_hash: Hash.sha256("faker"),
      previous_hash: Hash.sha256("other faker")
    }

    conn = get conn, transaction_path(conn, :edit, transaction.hash)
    response = html_response(conn, 200)

    assert response =~ "hwllo eorld"
    assert response =~ Hash.sha256("faker")
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    transaction = Repo.insert! %Transaction{
      data: %{"number" => "1", "note" => "hwllo eorld"},
      hash: Hash.sha256("faker"),
      originating_hash: Hash.sha256("faker"),
      previous_hash: Hash.sha256("other faker")
    }

    updates = %{
      data: %{number: 1, note: "hello world"}
    }

    conn = put conn, transaction_path(conn, :update, transaction.hash), transaction: updates
    assert redirected_to(conn) == transaction_path(conn, :index)
  end

  test "deletes a resource", %{conn: conn} do
    transaction = Repo.insert! %Transaction{
      data: %{"number" => "1", "note" => "hwllo eorld"},
      originating_hash: Hash.sha256("faker"),
      hash: Hash.sha256("faker"),
      previous_hash: Hash.sha256("previous faker")
    }

    conn = delete conn, transaction_path(conn, :delete, transaction.hash)
    assert redirected_to(conn) == transaction_path(conn, :index)
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, transaction_path(conn, :show, -1)
    end
  end
end
