defmodule Discuss.Images do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
#  alias Discuss.Topic

@derive { Jason.Encoder , only: [:id, :name_orign, :file_type, :updated_at , :name_uuid] }

  schema "images" do
    field :id_scene    , :integer
    field :name_orign  , :string
    field :name_uuid   , :string
    field :file_type   , :string
    field :name_status , :string

    timestamps()

    belongs_to :users ,Discuss.Users
    belongs_to :topic ,Discuss.Topic
  end

  def changeset( struct , params \\ %{}) do
    struct
    |> cast( params , [ :id_scene , :name_orign , :name_uuid , :file_type , :name_status ] )
    # |> validate_required( [:title , :discription] )
  end

  def ordered( query ) do
    from t in query,
    order_by: t.id
  end

end
