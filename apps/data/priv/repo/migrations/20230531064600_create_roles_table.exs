defmodule Data.Repo.Migrations.CreateRolesTable do
  use Data.Migration

  @table :roles
  def change do
    create table(@table) do
      add :title, :string
      add :name, :string
      timestamp()
    end
  end
end
