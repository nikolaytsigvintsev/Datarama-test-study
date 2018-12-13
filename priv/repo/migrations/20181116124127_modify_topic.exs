defmodule Discuss.Repo.Migrations.ModifyTopic do
  use Ecto.Migration

  def change do
    alter table(:topics) do
      add :discription, :text
    end
  end
end
