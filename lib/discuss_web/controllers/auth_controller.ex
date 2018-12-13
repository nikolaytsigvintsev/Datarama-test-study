defmodule DiscussWeb.AuthController do
  use DiscussWeb, :controller

   plug Ueberauth
   alias Discuss.Users
   alias Discuss.Repo

  def callback( %{ assigns: %{ ueberauth_auth: auth }} = conn , _params) do
    # IO.inspect( auth )
    user_params = %{ token: auth.credentials.token , email: auth.info.email , provider: "github" }
    changeset = Users.changeset( %Users{}, user_params )
    # IO.inspect( changeset )
    signin( conn , changeset )
  end

  def signout( conn , _params ) do
    conn
    |> configure_session( drop: true )
    |> redirect( to: Routes.main_path( conn , :index ))
  end

  defp signin( conn , changeset ) do
    case insert_or_update_user( changeset ) do
      { :ok , users } ->
        conn
        |> put_flash( :info , "Welcome")
        |> put_session( :user_id , users.id )
        |> redirect( to: Routes.admin_path( conn , :index ) )
      { :error , _reason } ->
        conn
        |> put_flash( :error , "Error signing in")
        |> redirect( to: Routes.main_path( conn , :index ) )
    end
  end


  defp insert_or_update_user( changeset ) do
    case Repo.get_by( Users, email: changeset.changes.email ) do
      nil  ->
          Repo.insert( changeset )
      users ->
        { :ok , users }
    end
  end
end
