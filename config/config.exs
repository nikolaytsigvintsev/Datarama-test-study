# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :discuss,
  ecto_repos: [Discuss.Repo]

# Configures the endpoint
config :discuss, DiscussWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "waLLP1d38TdM6JzfvB8m13/FV2PhML3Q8eQT9IwgiyTdJ2m+VXaUo3gjszf2sTtn",
  render_errors: [view: DiscussWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Discuss.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# List here all of your upload controllers
#config :tus, controllers: [DiscussWeb.UploadController]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

config :ueberauth, Ueberauth,
  providers: [
    # facebook: { Ueberauth.Strategy.Facebook, [ opt1: "value", opts2: "value" ] },
    github: { Ueberauth.Strategy.Github,  [ default_scope: "user,public_repo,notifications" , allow_private_emails: true ] },
    identity: { Ueberauth.Strategy.Identity, [
        callback_methods: ["POST"],
        scrub_params: false,
        uid_field: :email,
        nickname_field: :email,
        request_path: "/login",
        callback_path: "/login/identity/callback",
      ]}
  ]

config :ueberauth,Ueberauth.Strategy.Github.OAuth,
   client_id: "f5210c0d2e3582aacdca",
   client_secret: "d2ea46b7afb8b22294c18d2b8590cb2cc0432494"
    # client_id: System.get_env("GITHUB_CLIENT_ID"),
    # client_secret: System.get_env("GITHUB_CLIENT_SECRET")

config :google_maps,
  api_key: "AIzaSyDuohbU1xIqUfc7y4S31uTHLh9HGu2CTq0"

  config :arc,
    storage: Arc.Storage.Local #Arc.Storage.S3, #
  #   bucket: {:system, "AWS_S3_BUCKET"} # if using Amazon S3
  
  config :mime, :types, %{
    "application/vnd.api+json" => ["json-api"]
  }
