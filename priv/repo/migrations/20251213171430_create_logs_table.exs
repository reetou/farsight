defmodule Farsight.Repo.Migrations.CreateLogsTable do
  use Ecto.Migration

  def change do
    create table(:logs, primary_key: false) do
      add :id, :uuid, primary_key: true

      add :action, :text, null: false
      add :actor_id, :text, null: false
      add :target_id, :text, null: false
      add :environment, :text, null: false
      add :metadata, :map, null: false, default: %{}


      timestamps()
    end
  end
end
