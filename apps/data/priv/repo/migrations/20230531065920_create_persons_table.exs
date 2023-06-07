defmodule Data.Repo.Migrations.CreatePersonsTable do
  use Data.Migration

  @table :persons
  def change do
    create table(@table) do
      add :first_name, :string
      add :last_name, :string
      add :secondary_email, :jsonb
      add :secondary_phone_number, :jsonb
      add :gender, :string
      add :address, :string
      add :city, :string
      add :state, :string
      add :country, :string
      add :zip_code, :string
      add :user_id, references(:users, on_delete: :delete_all)
      timestamp()
    end

    create index(@table, [:user_id])
  end
end
