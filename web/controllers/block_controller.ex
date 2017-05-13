defmodule Noteblock.BlockController do
  use Noteblock.Web, :controller

  alias Noteblock.{Repo, Block, Hash}

  def index(conn, _params) do
    blocks = Repo.all(Block)
    render(conn, "index.html", blocks: blocks)
  end

  def new(conn, _params) do
    previous_block = get_last_block()

    new_hash = create_new_hash(previous_block)

    changeset = Block.changeset(%Block{
      previous_hash: Map.get(previous_block, :hash),
      hash: new_hash,
      originating_block: new_hash
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

  def show(conn, %{"id" => id}) do
    block = Repo.get!(Block, id)
    render(conn, "show.html", block: block)
  end

  def delete(conn, %{"id" => id}) do
    block = Repo.get! Block, id
    parent_data = Map.get block, :data
    previous_block = get_last_block()

    changeset = Block.changeset(%Block{
      originating_block: Map.get(block, :hash),
      previous_hash: Map.get(previous_block, :hash),
      hash: create_new_hash(previous_block),
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

  defp get_last_block do
    query = from n in Block, order_by: [desc: n.id], limit: 1
    Repo.one(query)
  end

  defp create_new_hash(block) do
    [
      Map.get(block, :hash),
      Map.get(block, :data),
      Map.get(block, :originating_block),
      Map.get(block, :inserted_at)
    ]
      |> Poison.encode
      |> Hash.sha256
  end
end
