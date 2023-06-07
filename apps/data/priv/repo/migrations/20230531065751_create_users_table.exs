defmodule Data.Repo.Migrations.CreateUsersTable do
  use Data.Migration

  @table :users
  def change do
    create table(@table) do
      add :email, :string
      add :password, :string
      add :phone_number, :string
      add :status, :string
      add :auto_generate_pass, :boolean
      add :is_social_login, :boolean
      timestamp()
    end

    create unique_index(@table, [:email])
  end
end
