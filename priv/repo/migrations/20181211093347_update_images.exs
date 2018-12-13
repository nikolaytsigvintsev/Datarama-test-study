defmodule Discuss.Repo.Migrations.UpdateImages do
  use Ecto.Migration

  def change do
    alter table(:images) do
      add :topic_id,references(:topics)
    end
  end
end
