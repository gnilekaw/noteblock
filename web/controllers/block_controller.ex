defmodule Noteblock.BlockController do
  use Noteblock.Web, :controller

  alias Noteblock.{Repo, Block, Hash}

  def index(conn, _params) do
    blocks = Repo.all(from b in Block, order_by: [desc: b.id])
    render(conn, "index.html", blocks: blocks)
  end

  def new(conn, _params) do
    last_block = last_block()

    changeset = Block.changeset(%Block{
      originating_block: last_block.originating_block,
      previous_hash: last_block.hash
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

  def edit(conn, %{"hash" => hash}) do
    block = Repo.get_by!(Block, hash: hash)
    changeset = Block.changeset(block)
    render(conn, "edit.html", block: block, data: block.data, changeset: changeset)
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
      originating_block: block.originating_block,
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
end
