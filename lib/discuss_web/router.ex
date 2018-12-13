defmodule DiscussWeb.Router do
  use DiscussWeb, :router

  pipeline :browser do
    plug :accepts, ["html" , "json-api"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Discuss.Plugs.SetUser
  end


  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :main_layout do
    plug :put_layout, {DiscussWeb.LayoutView, :main}
  end

  scope "/", DiscussWeb do   # /main
     pipe_through [:browser, :main_layout]
     get "/", MainController , :index
  end

  scope "/topics", DiscussWeb do
    pipe_through [:browser]

    #get "/", PageController, :index
    # get "/topics/new", TopicController, :new
    # post "/topics", TopicController, :create
    # get "/topics", TopicController, :index
    # get "/topics/:id/edit", TopicController, :edit
    # put "/topics/:id", TopicController, :update
    # get "/topics/:id", TopicController, :delete
    #
    resources "/" , TopicController


  end

  scope "/auth" , DiscussWeb do
      pipe_through :browser

      get "/signout" , AuthController, :signout
      get "/:provider" , AuthController , :request
      get "/:provider/callback" , AuthController ,:callback
  end

  scope "/admin" , DiscussWeb do
         pipe_through [:browser]

      get "/" , AdminController , :index
      get "/new" , AdminController , :new
      post "/", AdminController, :create
      get "/:id/edit", AdminController, :edit
      put "/:id", AdminController, :update
      delete "/:id", AdminController, :delete

  end

  scope "/login", DiscussWeb do
      pipe_through [:browser]
      get "/" , LoginController, :index
      # get "/new", LoginController, :new
      post "/identity/callback", LoginController, :identity_callback
  end

  scope "/sessions", DiscussWeb do
      pipe_through [:browser]
      get "/new", SessionsController, :new
      post "/identity/callback", SessionsController, :identity_callback
  end

   # scope "/files", DiscussWeb do
   #    options("/", UploadController, :options)
   #    match(:head, "/:uid", UploadController, :head)
   #    post("/", UploadController, :post)
   #    patch("/:uid", UploadController, :patch)
   #    delete("/:uid", UploadController, :delete)
   #  end

  # Other scopes may use custom stacks.
  # scope "/api", DiscussWeb do
  #   pipe_through :api
  # end
end
