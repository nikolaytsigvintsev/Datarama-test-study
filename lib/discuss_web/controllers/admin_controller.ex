defmodule DiscussWeb.AdminController do
  use DiscussWeb, :controller

  alias Discuss.Users
  alias Discuss.Repo

  plug Discuss.Plugs.RequireAuth when action in [ :index ,:new , :create , :edit , :update , :delete ]

   def index( conn , _params) do
     listuser =
       Users
       |> Users.ordered
       |> Repo.all

     # IO.inspect( conn )

     render( conn , "index.html" , listuser: listuser )
   end

   def new( conn , _params ) do
     struct = %Users{}
     params = %{}

     changeset = Users.changeset( struct , params )

     render(conn, "new.html" , changeset: changeset)
   end

   def create( conn , %{ "users" => newuser } ) do
 #-----------??????????????????????
       newuser = Map.replace!( newuser , "password", Comeonin.Bcrypt.hashpwsalt( Map.get( newuser , "password") ))
 #================================
       changeset = Users.changeset( %Users{} , Map.merge( newuser ,%{ "provider" => "identify" , "token"  => "sdfsdfsdf"} ))

        IO.inspect changeset
       case Repo.insert( changeset ) do
         {:ok , _post }         -> #IO.inspect(post)
            conn
            |> put_flash( :info ,"User created")
            |> redirect( to: Routes.admin_path( conn , :index ))
          {:error , changeset } ->
              render conn , "new.html" , changeset: changeset
      end
  end

  def edit( conn ,  %{ "id" => users_id } ) do
    user = Repo.get( Users,users_id )

    changeset = Users.changeset( user )

    render conn, "edit.html" , changeset: changeset ,user: user
  end

  def delete( conn ,  %{ "id" => users_id } ) do

          Repo.get!( Users,users_id )
          |> Repo.delete!

          conn
          |> put_flash( :info ,"User deleted")
          |> redirect( to: Routes.admin_path( conn , :index ))

  end

  def update( conn ,  %{ "id" => users_id , "users" => user } ) do

    changeset = Repo.get( Users,users_id )
                |> Users.changeset( user )

    case Repo.update( changeset ) do
      {:ok , _post }         -> #IO.inspect(post)
        conn
        |> put_flash( :info ,"User updated")
        |> redirect( to: Routes.admin_path( conn , :index ))
      {:error , changeset } ->
        render conn , "new.html" , changeset: changeset
    end
  end


end
