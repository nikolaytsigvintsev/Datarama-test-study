defmodule DiscussWeb.UploadsChannel do
  use Phoenix.Channel
  # import Plug.MIME

  alias Ecto.UUID
  alias Discuss.{ Topic , Images , Repo , FileUploader ,Users }


  def join("uploads:" <> topic_id, _message, socket) do
     topic_id = String.to_integer( topic_id )

     topic = Repo.get( Topic , topic_id )
       |> Repo.preload( :images )


     {:ok, %{ images: topic.images } , assign( socket , :topic , topic ) }
  end

  def handle_in("upload:file", params, socket) do
     topic = socket.assigns.topic

     basename = params["filename"]
     extension = Path.extname( basename )
     namefile = UUID.generate

     result = Map.put(params , "filename" , "#{namefile}#{extension}" )
     |> keys_to_atoms()
     |> decode_binary()
     |> FileUploader.store()

      {:ok , value } = result
      IO.inspect value
      IO.inspect File.read!( "uploads/#{value}")
     case result do
       { :ok , filename } ->
         # IO.inspect File.open( "uploads/#{filename}")
        # case File.open( filename ) do
        #  { :ok , filename } ->
           changeset = topic
           |> Ecto.build_assoc( :images , users_id: socket.assigns.users_id )
           |> Images.changeset( %{ :name_uuid => filename , :name_orign => basename , :file_type => MIME.from_path( filename ) }) #IO.inspect MIME.from_path( filename )

           case Repo.insert( changeset ) do
             {:ok , file_info }         ->
               # broadcast!( socket , "uploads:#{topic.id}:new",%{ content: file_info } )
               { :reply , {:ok ,%{contents: file_info}}, socket }

             {:error , changeset } ->
                 { :reply , { :error , %{ errors: changeset }}, socket }
            end
        #  { :error , _ } ->
        #       { :reply , { :error ,socket }}
        # end
       { :error , _ } ->
          { :reply , { :error ,socket }}
     end

      # {:noreply, socket}
  end

  defp keys_to_atoms(params) do
    Map.new(params, fn {k, v} -> {String.to_atom(k), v} end)
  end

  defp decode_binary(params) do
    Map.put(params, :binary, Base.decode64!(params.binary))
  end


  def handle_in("uploads:add", %{ "files_info" => file_info }, socket) do
    topic = socket.assigns.topic

    basename  = Path.basename( file_info )
    extension = Path.extname( basename )
    namefile = UUID.generate

    # IO.inspect basename

    changeset = topic
      |> Ecto.build_assoc( :images , users_id: socket.assigns.users_id )
      |> Images.changeset( %{ :name_uuid => "#{namefile}#{extension}" , :name_orign => basename })

      IO.inspect changeset
      case Repo.insert( changeset ) do
        {:ok , _ }         -> #IO.inspect(post)
          broadcast!( socket , "uploads:#{topic.id}:new",%{ file_info: nil } )
          { :reply , :ok , socket }
        {:error , changeset } ->
            { :reply , { :error , %{ errors: changeset }}, socket }
      end


     # { :reply , :ok , socket }
  end
end
