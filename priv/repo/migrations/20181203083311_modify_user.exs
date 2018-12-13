defmodule Discuss.Repo.Migrations.ModifyUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :name, :string
      add :password , :string
    end
  end
end
