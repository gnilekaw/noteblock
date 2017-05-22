defmodule Noteblock.TransactionController do
  use Noteblock.Web, :controller

  alias Noteblock.{Repo, Transaction, Hash}

  def index(conn, _params) do
    transactions = Repo.all(from b in Transaction, order_by: [desc: b.id])
    render(conn, "index.html", transactions: transactions)
  end

  def verify_ledger(conn, _params) do
    [transaction_1, transaction_2] = last_two_transactions()
    # TODO: This only verifies TWO transactions, lol
    status = case Hash.verify(transaction_1, transaction_2) do
      true -> "Verified"
      false -> "Errors"
    end

    render(conn, "verify_ledger.html", status: status)
  end

  def new(conn, _params) do
    changeset = Transaction.changeset(%Transaction{})
    render(
      conn,
      "new.html",
      changeset: changeset,
      disabled: disabled_form(changeset.data.data)
    )
  end

  def create(conn, %{"transaction" => transaction_params}) do
    %{hash: previous_hash} = last_transaction()

    data = Map.put(transaction_params["data"], "action", "create")

    {:ok, hash} = Hash.new %{
      previous_hash: previous_hash,
      data: data
    }

    transaction = %{
      data: data,
      previous_hash: previous_hash,
      hash: hash,
      originating_hash: hash
    }

    changeset = Transaction.changeset(%Transaction{}, transaction)

    case Repo.insert(changeset) do
      {:ok, transaction} ->
        conn
        |> put_flash(:info, "Transaction created successfully.")
        |> redirect(to: transaction_path(conn, :show, transaction.hash))
      {:error, changeset} ->
        render(conn,
          "new.html",
          changeset: changeset,
          disabled: disabled_form(changeset.data.data)
        )
    end
  end

  def show(conn, %{"hash" => hash}) do
    transaction = Repo.get_by!(Transaction, hash: hash)

    query = from b in Transaction,
      where: b.originating_hash == ^transaction.originating_hash,
      order_by: [desc: b.id]

    [transaction | history] = Repo.all(query)

    render(
      conn,
      "show.html",
      transaction: transaction,
      history: history,
      disabled: disabled_form(transaction.data)
    )
  end

  def edit(conn, %{"hash" => hash}) do
    transaction = Repo.get_by!(Transaction, hash: hash)
    changeset = Transaction.changeset(transaction)
    render(
      conn,
      "edit.html",
      transaction: transaction.hash,
      disabled: disabled_form(changeset.data.data),
      changeset: changeset
    )
  end

  defp disabled_form(data) do
    case data["action"] do
      "delete" -> %{edit_number: true, edit_note: true, submit: true}
      _ -> %{edit_number: false, edit_note: false, submit: false}
    end
  end

  def update(conn, %{"hash" => hash, "transaction" => transaction_params}) do
    transaction = Repo.get_by! Transaction, hash: hash

    %{hash: previous_hash} = last_transaction()

    data = Map.put(transaction_params["data"], "action", "update")

    {:ok, hash} = Hash.new %{
      previous_hash: previous_hash,
      data: data
    }

    changeset = Transaction.changeset(%Transaction{
      hash: hash,
      previous_hash: previous_hash,
      originating_hash: transaction.originating_hash,
      data: data
    })

    case Repo.insert(changeset) do
      {:ok, _transaction} ->
        conn
        |> put_flash(:info, "Transaction updated successfully.")
        |> redirect(to: transaction_path(conn, :show, transaction.hash))
      {:error, changeset} ->
        render(conn, "edit.html", transaction: transaction, changeset: changeset)
    end
  end

  def delete(conn, %{"hash" => id}) do
    transaction = Repo.get_by! Transaction, hash: id

    %{hash: previous_hash} = last_transaction()

    data = %{
      action: "delete",
      number: Map.get(transaction.data, "number"),
      note: nil
    }

    {:ok, hash} = Hash.new %{
      previous_hash: previous_hash,
      data: data
    }

    changeset = Transaction.changeset(%Transaction{
      originating_hash: transaction.originating_hash,
      previous_hash: previous_hash,
      hash: hash,
      data: data
    })

    case Repo.insert(changeset) do
      {:ok, _transaction} ->
        conn
        |> put_flash(:info, "Transaction deleted successfully.")
        |> redirect(to: transaction_path(conn, :index))
      {:error, changeset} ->
        render(conn, "edit.html", transaction: transaction, changeset: changeset)
    end
  end

  defp last_transaction do
    Transaction |> Transaction.last |> Repo.one
  end

  defp last_two_transactions do
    Transaction |> Transaction.last_two |> Repo.all
  end
end
