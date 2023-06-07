defmodule Data.Repo.Migrations.CreateFilesTable do
  use Data.Migration

  @table :files
  def change do
    create table(@table) do
      add :title, :string
      add :description, :string
      add :comments, :text
      add(:path, :string)
      add(:mime, :string)
      add(:type, :string)
      add :file_type, {:array, :string}
      add :file, :jsonb
      add :date, :date
      add :check_image, :boolean, default: false, null: false
      add :check_video, :boolean, default: false, null: false
      add :check_report, :boolean, default: false, null: false
      add :image, :jsonb
      add :video, :jsonb
      add :report, :jsonb
      timestamp()
    end
  end
end
