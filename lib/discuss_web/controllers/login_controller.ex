defmodule DiscussWeb.LoginController do
  use DiscussWeb, :controller
  import Plug.Conn

  alias Ueberauth.Strategy.Helpers
  plug Ueberauth

  alias Discuss.{ Users , Repo }


  def index(conn, _params) do
    # render conn, "new.html", callback_url: Helpers.callback_url(conn)
          render(conn,layout: { DiscussWeb.LayoutView , "login.html"} , callback_url: Helpers.callback_url(conn) )
  end

  def identity_callback(%{assigns: %{ueberauth_auth: auth}} = conn, _) do
    conn
    |> authenticated( Users.authenticate( auth ) )
  end

  defp authenticated(conn, {:ok, users}) do
        # after autentification generate token and write it to DB
        token = Phoenix.Token.sign( conn, "user salt", users.id )

        changeset = Repo.get( Users,users.id )
            |> Users.changeset( %{ token: token } )

        case Repo.update( changeset ) do
        {:ok , _users }         -> #IO.inspect(post)
          conn
          |> put_flash(:info, "Successfully authenticated.")
          |> put_session( :user_id , users.id)
          |> redirect(to: Routes.admin_path( conn , :index ))
       {:error , _changeset } ->
         conn
         |> put_flash(:error, "Error authenticated.")
         |> configure_session( drop: true )
         |> redirect( to: Routes.main_path( conn , :index ))

    end
  end

  defp authenticated(conn, {:error, error}) do
    conn
    |> put_flash(:error, error)
    |> redirect(to: "/login")
  end

end
