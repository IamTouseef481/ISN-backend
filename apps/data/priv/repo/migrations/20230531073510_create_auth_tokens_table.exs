defmodule Data.Repo.Migrations.CreateAuthTokensTable do
  use Data.Migration

  @table :auth_tokens
  def change do
    create table(@table) do
      add :token, :string
      add :subject, :string
      add :user_id, references(:users, on_delete: :delete_all)
      timestamp()
    end

    create index(@table, [:token, :user_id])
  end
end
