defmodule Discuss.Comment do
  use Ecto.Schema
  import Ecto.Changeset

@derive { Jason.Encoder , only: [:id,:content] }

  schema "comments" do
    field :content, :string

    timestamps()

    belongs_to :users ,Discuss.Users
    belongs_to :topic ,Discuss.Topic
  end

  def changeset( struct , params \\ %{}) do
    struct
    |> cast( params , [:content] )
    |> validate_required([:content])
  end

end
