defmodule Discuss.Plugs.RequireAuth do
use DiscussWeb, :controller

import Plug.Conn
import Phoenix.Controller

  def init( _params ) do

  end

  def call( conn , _params ) do
    # IO.inspect conn
    if conn.assigns[:users] do
      conn
    else
      conn
      |> put_flash( :error , "You must be logged in.")
      |> redirect(to: Routes.main_path(conn, :index))
      |> halt
    end
  end

end
