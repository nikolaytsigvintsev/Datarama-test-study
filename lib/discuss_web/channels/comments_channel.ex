defmodule DiscussWeb.CommentsChannel do
  use Phoenix.Channel

  alias Discuss.{Topic , Comment , Repo }

  def join("comments:" <> topic_id, _message, socket) do
     topic_id = String.to_integer( topic_id )

     topic = Repo.get( Topic , topic_id )
       |> Repo.preload( :comments )


     {:ok, %{ comments: topic.comments } , assign( socket , :topic , topic ) }
  end

  # def join("comments:" <> _private_room_id, _params, _socket) do
  #   {:error, %{reason: "unauthorized"}}
  # end

  def handle_in("comments:add", %{ "content" => content }, socket) do
    topic = socket.assigns.topic

    changeset = topic
      |> Ecto.build_assoc( :comments , users_id: socket.assigns.users_id )
      |> Comment.changeset( %{ content: content })

      # IO.inspect changeset
      case Repo.insert( changeset ) do
        {:ok , comment }         -> #IO.inspect(post)
          broadcast!( socket , "comments:#{topic.id }:new",%{ content: comment } )
          { :reply , :ok , socket }
        {:error , changeset } ->
            { :reply , { :error , %{ errors: changeset }}, socket }
      end


    # { :reply , :ok , socket }
  end

  def handle_in("comments:delete",%{ "id" => id_del }, socket) do
    topic = socket.assigns.topic

      Repo.get!( Comment,String.to_integer( id_del ))
      |> Repo.delete!

      topic =  Repo.get( Topic , topic.id )
      |> Repo.preload( :comments )

      broadcast!( socket , "comments:#{topic.id}:delete",%{ comments: topic.comments } )


      #
      { :reply , :ok , socket }
  end

end
