defmodule Discuss.Topic do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
#  alias Discuss.Topic

  schema "topics" do
    field :title       , :string
    field :discription , :string
    field :status      , :string

    belongs_to :users ,Discuss.Users
    has_many :comments,Discuss.Comment , on_delete: :delete_all
    has_many :images,Discuss.Images ,  on_delete: :delete_all
  end

  def changeset( struct , params \\ %{}) do
    struct
    |> cast( params , [:title , :discription, :status] )
    |> validate_required( [:title , :discription] )
  end

  def ordered( query ) do
    from t in query,
    order_by: t.id
  end

end
