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
  end
end
