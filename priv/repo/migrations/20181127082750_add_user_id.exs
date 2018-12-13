defmodule Discuss.Repo.Migrations.AddUserId do
  use Ecto.Migration

  def change do
    alter table(:topics) do
      add :user_id, references( :users )
    end
    
    alter table(:images) do
      add :user_id, references( :users )
    end
  end
end
