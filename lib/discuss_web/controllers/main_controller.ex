defmodule DiscussWeb.MainController do
  use DiscussWeb, :controller

  def index(conn, _params) do
   # render(conn,  layout: { DiscussWeb.LayoutView , "main.html"} )
        render conn , "index.html"
  end
end
