defmodule Discuss.Plugs.SetUser do
  use DiscussWeb, :controller
  import Plug.Conn
  # import Phoenix.Controller

  alias Discuss.Repo
  alias Discuss.Users
  # alias Discuss.Router.Helpers

  def init( _params ) do

  end

  def call( conn , _params ) do
    user_id = get_session( conn , :user_id )
    cond do
      user = user_id && Repo.get( Users, user_id) ->
        assign( conn , :users , user )
      true ->
        assign( conn , :users , nil)
    end

  end
end
