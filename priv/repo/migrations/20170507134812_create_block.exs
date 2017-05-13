defmodule Noteblock.Repo.Migrations.CreateBlock do
  use Ecto.Migration

  def change do
    create table(:blocks) do
      add :hash, :string
      add :previous_hash, :string
      add :data, :map
      add :originating_block, :string
      timestamps()
    end

  end
end
