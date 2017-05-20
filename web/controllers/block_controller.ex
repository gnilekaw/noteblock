defmodule Noteblock.BlockController do
  use Noteblock.Web, :controller

  alias Noteblock.{Repo, Block, Hash}

  def index(conn, _params) do
    blocks = Repo.all(from b in Block, order_by: [desc: b.id])
    render(conn, "index.html", blocks: blocks)
  end

  def verify_ledger(conn, _params) do
    [block_1, block_2] = last_two_blocks()
    # TODO: This only verifies TWO blocks, lol
    status = case Hash.verify(block_1, block_2) do
      true -> "Verified"
      false -> "Errors"
    end

    render(conn, "verify_ledger.html", status: status)
  end

  def new(conn, _params) do
    changeset = Block.changeset(%Block{})
    render(
      conn,
      "new.html",
      changeset: changeset,
      disabled: disabled_form(changeset.data.data)
    )
  end

  def create(conn, %{"block" => block_params}) do
    %{hash: previous_hash} = last_block()

    data = Map.put(block_params["data"], "action", "create")

    {:ok, hash} = Hash.new %{
      previous_hash: previous_hash,
      data: data
    }

    block = %{
      data: data,
      previous_hash: previous_hash,
      hash: hash,
      originating_block: hash
    }

    changeset = Block.changeset(%Block{}, block)

    case Repo.insert(changeset) do
      {:ok, _block} ->
        conn
        |> put_flash(:info, "Block created successfully.")
        |> redirect(to: block_path(conn, :index))
      {:error, changeset} ->
        render(conn,
          "new.html",
          changeset: changeset,
          disabled: disabled_form(changeset.data.data)
        )
    end
  end

  def show(conn, %{"hash" => hash}) do
    block = Repo.get_by!(Block, hash: hash)

    query = from b in Block,
      where: b.originating_block == ^block.originating_block,
      order_by: [desc: b.id]

    [block | history] = Repo.all(query)

    render(
      conn,
      "show.html",
      block: block,
      history: history,
      disabled: disabled_form(block.data)
    )
  end

  def edit(conn, %{"hash" => hash}) do
    block = Repo.get_by!(Block, hash: hash)
    changeset = Block.changeset(block)
    render(
      conn,
      "edit.html",
      block: block.hash,
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

  def update(conn, %{"hash" => hash, "block" => block_params}) do
    block = Repo.get_by! Block, hash: hash

    %{hash: previous_hash} = last_block()

    data = Map.put(block_params["data"], "action", "update")

    {:ok, hash} = Hash.new %{
      previous_hash: previous_hash,
      data: data
    }

    changeset = Block.changeset(%Block{
      hash: hash,
      previous_hash: previous_hash,
      originating_block: block.originating_block,
      data: data
    })

    case Repo.insert(changeset) do
      {:ok, _block} ->
        conn
        |> put_flash(:info, "Block updated successfully.")
        |> redirect(to: block_path(conn, :index))
      {:error, changeset} ->
        render(conn, "edit.html", block: block, changeset: changeset)
    end
  end

  def delete(conn, %{"hash" => id}) do
    block = Repo.get_by! Block, hash: id

    %{hash: previous_hash} = last_block()

    data = %{
      action: "delete",
      number: Map.get(block.data, "number"),
      note: nil
    }

    {:ok, hash} = Hash.new %{
      previous_hash: previous_hash,
      data: data
    }

    changeset = Block.changeset(%Block{
      originating_block: block.originating_block,
      previous_hash: previous_hash,
      hash: hash,
      data: data
    })

    case Repo.insert(changeset) do
      {:ok, _block} ->
        conn
        |> put_flash(:info, "Block deleted successfully.")
        |> redirect(to: block_path(conn, :index))
      {:error, changeset} ->
        render(conn, "edit.html", block: block, changeset: changeset)
    end
  end

  defp last_block do
    Block |> Block.last |> Repo.one
  end

  defp last_two_blocks do
    Block |> Block.last_two |> Repo.all
  end
end
