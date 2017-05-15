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
    |> validate_number(:data)
    |> validate_action(:data)
  end

  defp validate_number(changeset, field) do
    validate_change(changeset, field, fn _field, data ->

      valid_conditions = Map.has_key?(data, "number") and String.length(data["number"]) > 0

      case valid_conditions do
        true -> []
        false -> [data: "data[number] cannot be nil"]
      end
    end)
  end

  defp validate_action(changeset, field) do
    validate_change(changeset, field, fn _field, data ->
      case Map.has_key?(data, "action") do
        true -> []
        false -> [data: "data[action] cannot be nil"]
      end
    end)
  end

  @doc """
  Gets the last block from the chain.
  """
  def last(block) do
    from n in block, order_by: [desc: n.id], limit: 1
  end
end
