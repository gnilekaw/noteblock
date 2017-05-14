defmodule Noteblock.BlockController do
  use Noteblock.Web, :controller

  alias Noteblock.{Repo, Block, Hash}

  def index(conn, _params) do
    blocks = Repo.all(from b in Block, order_by: [desc: b.id])
    render(conn, "index.html", blocks: blocks)
  end

  def new(conn, _params) do
    last_block = Block |> Block.last |> Repo.one

    new_hash = Hash.new(last_block)

    changeset = Block.changeset(%Block{
      originating_block: new_hash,
      previous_hash: Map.get(last_block, :hash),
      hash: new_hash
    })

    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"block" => block_params, "data" => data_params}) do
    changeset = Block.changeset(
      %Block{},
      Map.put(block_params, "data", data_params)
    )

    case Repo.insert(changeset) do
      {:ok, _block} ->
        conn
        |> put_flash(:info, "Block created successfully.")
        |> redirect(to: block_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"hash" => hash}) do
    block = Repo.get_by!(Block, hash: hash)
    render(conn, "show.html", block: block)
  end

  def delete(conn, %{"hash" => hash}) do
    block = Repo.get_by! Block, hash: hash
    parent_data = Map.get block, :data
    last_block = Block |> Block.last |> Repo.one

    changeset = Block.changeset(%Block{
      originating_block: Map.get(block, :hash),
      previous_hash: Map.get(last_block, :hash),
      hash: Hash.new(last_block),
      data: %{
        action: "delete",
        number: Map.get(parent_data, "number"),
        note: nil
      }
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
end
