defmodule Data.Repo.Migrations.CreateUserRolesTable do
  use Data.Migration

  @table :user_roles
  def change do
    create table(@table) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :role_id, references(:roles, on_delete: :delete_all), null: false
      timestamp()
    end

    create index(@table, [:role_id, :user_id])
  end
end
