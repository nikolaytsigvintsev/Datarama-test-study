defmodule Discuss.Users do

  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  import Comeonin.Bcrypt

  alias Ueberauth.Auth
  alias Discuss.Repo


  schema "users" do
    field :email, :string
    field :provider , :string
    field :token , :string
    field :name, :string
    field :password, :string

    has_many :topics, Discuss.Topic  , on_delete: :delete_all
    has_many :images, Discuss.Images , on_delete: :delete_all
    has_many :comments,Discuss.Comment , on_delete: :delete_all

    timestamps()
  end

  def changeset( struct , params \\ %{}) do
    struct
    |> cast( params , [:email, :token , :provider , :name , :password] )
    |> validate_required( [:email , :token , :provider ,:name , :password] )
    |> unique_constraint(:email)
  end

  def authenticate(%Auth{provider: :identity} = auth) do
     Repo.get_by(__MODULE__, email: auth.uid)
     |> authorize(auth)
   end

   defp authorize(nil,_auth), do: {:error, "Invalid username or password"}
   defp authorize(user, auth) do
      checkpw(auth.credentials.other.password, user.password)
      |> resolve_authorization(user)
   end

 defp resolve_authorization(false, _user), do: {:error, "Invalid username or password"}
 defp resolve_authorization(true, user), do: {:ok, user}

  def ordered( query ) do
    from t in query,
    order_by: t.id
  end
end
