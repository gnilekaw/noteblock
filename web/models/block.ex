defmodule Noteblock.Block do
  use Noteblock.Web, :model

  schema "blocks" do
    field :hash, :string
    field :previous_hash, :string
    field :data, :map
    field :originating_block, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:hash, :previous_hash, :data, :originating_block])
    |> validate_required([:hash, :previous_hash, :data, :originating_block])
    |> validate_map(:data)
  end

  def validate_map(changeset, field) do
    validate_change(changeset, field, fn _field, data ->
      if String.length(data["number"]) > 0 && String.to_integer(data["number"]) do
        []
      else
        [data: "data[number] cannot be nil"]
      end
    end)
  end

  @doc """
  Gets the last block from the chain.
  """
  def last(query) do
    from n in query, order_by: [desc: n.id], limit: 1
  end
end
