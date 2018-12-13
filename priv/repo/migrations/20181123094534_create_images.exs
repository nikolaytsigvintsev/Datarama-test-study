defmodule Discuss.Repo.Migrations.CreateImages do
  use Ecto.Migration

  def change do
    create table( :images ) do
      add :id_scene    , :integer
      add :name_orign  , :string
      add :name_uuid   , :string
      add :file_type   , :string
      add :name_status , :string

      timestamps()
    end

    alter table(:topics) do
        add :status, :string
      end
  end
end
