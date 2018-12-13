defmodule Discuss.Repo.Migrations.ChangeModelsForDeleteReference do
  use Ecto.Migration

  def up do
    execute "ALTER TABLE comments DROP CONSTRAINT comments_topic_id_fkey"
    alter table(:comments) do
      modify(:topic_id, references(:topics , on_delete: :nothing))
    end
  end
  def down do
    execute "ALTER TABLE comments DROP CONSTRAINT comments_topic_id_fkey"
    alter table(:comments) do
      modify(:topic_id, references(:topics , on_delete: :delete_all))
    end
  end

  def up do
    execute "ALTER TABLE comments DROP CONSTRAINT comments_users_id_fkey"
    alter table(:comments) do
      modify(:users_id, references(:users , on_delete: :nothing))
    end
  end
  def down do
    execute "ALTER TABLE comments DROP CONSTRAINT comments_users_id_fkey"
    alter table(:comments) do
      modify(:users_id, references(:users , on_delete: :delete_all))
    end
  end

  # def change do
  #   alter table(:comments) do
  #     references(:topics , on_delete: :delete_all)
  #     references(:users , on_delete: :delete_all)
  #   end
  #   alter table(:images) do
  #     references(:topics , on_delete: :delete_all)
  #     references(:users , on_delete: :delete_all)
  #   end
  #   alter table(:topics) do
  #     references(:users , on_delete: :delete_all)
  # end
end
