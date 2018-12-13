defmodule DiscussWeb.TopicController do
  use DiscussWeb, :controller
#  use Repo
  import Ecto.Query

  alias Ecto.UUID
  alias Discuss.Topic
  alias Discuss.Images
  alias Discuss.Repo


  @dir_uploads 'priv/static/uploads'

  plug Discuss.Plugs.RequireAuth when action in [ :index, :new , :create , :edit , :update , :delete ]
  plug :check_topic_owner when action in [ :update , :edit , :delete ]

  def check_topic_owner( conn ,_patams) do
    %{ params: %{"id" => topic_id }} = conn

    if Repo.get( Topic , topic_id ).users_id == conn.assigns.users.id do
      conn
    else
      conn
      |> put_flash( :error , "You connot edit that !!!" )
      |> redirect( to: Routes.topic_path( conn , :index ))
      |> halt()
    end
  end

  def new( conn , _params ) do
    struct = %Topic{}
    params = %{}

    changeset = Topic.changeset( struct , params )

    render(conn, "new.html" , changeset: changeset)
  end

  def show( conn , %{ "id"=> topic_id }) do
    topic = Repo.get( Topic ,topic_id )

    topics = from(r in Images, where: r.id_scene == ^topic.id )
    |> Repo.one()
    |> create_path_to_image
    |> Map.merge( topic )

    changeset = Topic.changeset( topic )
    # IO.puts "============================================"
     # IO.inspect

    render(conn, "show.html" ,changeset: changeset, topic: topics)
  end

  def edit( conn ,  %{ "id" => topic_id } ) do
    topic = Repo.get( Topic,topic_id )

    changeset = Topic.changeset( topic )
    render(conn, "edit.html" , changeset: changeset ,topic: topic)
  end

  def delete( conn ,  %{ "id" => topic_id } ) do

      nf = from(r in Images, where: r.id_scene == ^topic_id )
              |> Repo.one()
              |> create_path_to_image

    case File.rm( "#{Path.dirname( @dir_uploads )}/#{nf.pathfile}" ) do
        :ok   ->
          from(r in Images, where: r.id_scene == ^topic_id )
          |> Repo.one
          |> Repo.delete!

          Repo.get!( Topic,topic_id )
          |> Repo.delete!

          conn
          |> put_flash( :info ,"Scene deleted")
          |> redirect( to: Routes.topic_path( conn , :index ))

      { :error , _param } ->
          conn
          |> put_flash( :error ,"Error scene deleted . Error delete files.")
          |> redirect( to: Routes.topic_path( conn , :index ))
    end

  #    render conn , "index.html" ,
  end

  def update( conn ,  %{ "id" => topic_id , "topic" => topic } ) do

    changeset = Repo.get( Topic,topic_id )
                |> Topic.changeset( topic )

    case Repo.update( changeset ) do
      {:ok , _post }         -> #IO.inspect(post)
        conn
        |> put_flash( :info ,"Scene updated")
        |> redirect( to: Routes.topic_path( conn , :index ))
      {:error , changeset } ->
        render conn , "new.html" , changeset: changeset
    end
  end

  def create( conn , %{ "topic" => topic } ) do
    # changeset = Topic.changeset( %Topic{} , topic )

    changeset = conn.assigns.users
                |> Ecto.build_assoc( :topics )
                |> Topic.changeset( topic )

    # IO.inspect changeset

    if upload = topic["photo"] do
        extension = Path.extname(upload.filename)
        # namefile = :crypto.hash(:md5 , UUID.uuid4(:hex,upload.filename ) )
        # namefile = UUID.uuid5(:dns,upload.filename )
        namefile = UUID.generate
        # |> Base.encode16()

        # IO.inspect "#{namefile}.#{extension}"
        s = File.cp!(upload.path, "#{@dir_uploads}/#{namefile}#{extension}")
        if :ok == s  do        ##{user.id}-
            case Repo.insert( changeset ) do
              {:ok , post }         -> #IO.inspect(post)
                insert_db_image( conn ,%{ :id_scene => post.id  , :name_orign => upload.filename , :name_uuid => "#{namefile}#{extension}" ,:file_type => upload.content_type })
                conn
                |> put_flash( :info ,"Scene created")
                |> redirect( to: Routes.topic_path( conn , :index ))
              {:error , changeset } ->
                render conn , "new.html" , changeset: changeset
            end
        else
            conn
            |> put_flash( :error ,"Error upload files !")
            |> redirect( to: Routes.topic_path( conn , :new ))
            #render conn , "new.html" , changeset: changeset
        end
    else
      conn
      |> put_flash( :error ,"Error upload files !")
      |> redirect( to: Routes.topic_path( conn , :new ))
    end
  end

  defp insert_db_image( conn ,params ) do
    # IO.inspect( params )
    # changeset = Images.changeset( %Images{} , params  )
    # IO.inspect( changeset )

    changeset = conn.assigns.users
                |> Ecto.build_assoc( :images )
                |> Images.changeset( params )

    case Repo.insert( changeset ) do
      {:ok , post }         -> IO.inspect(post)
    end
  end

  defp create_path_to_image( images ) do
    %{ :pathfile => "#{ Path.basename( @dir_uploads ) }/#{images.name_uuid}" }
  end

  def index( conn , _params) do

    topics =
      Topic
      |> Topic.ordered
      |> Repo.all

    # IO.inspect GoogleMaps.directions("Toronto", "Montreal",key:  "AIzaSyDuohbU1xIqUfc7y4S31uTHLh9HGu2CTq0")
    topics = for topic <- topics do
                from(r in Images, where: r.id_scene == ^topic.id )
                |> Repo.one()
                |> create_path_to_image
                |> Map.merge( topic )
             end
    # IO.inspect( conn )
    render conn , "index.html" , layout: { DiscussWeb.LayoutView , "app.html"} ,topics: topics
  end
end
