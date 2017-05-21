defmodule Noteblock.Repo.Migrations.CreateBlock do
  use Ecto.Migration

  def change do
    create table(:transactions) do
      add :hash, :string
      add :previous_hash, :string
      add :data, :map
      add :originating_hash, :string
      timestamps()
    end

  end
end
