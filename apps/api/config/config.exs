# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

# Configures the endpoint
config :api, ApiWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [json: ApiWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Api.PubSub,
  live_view: [signing_salt: "Fq2Cs8wx"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#

# configuratiion for the guardian secret key
config :api, Api.GuardianHelper.Guardian,
  issuer: "api",
  secret_key: "5iRwAVXnFrQYJ3wtbr6gs3wCZYimIoUup5nwYU323GRrG/OspKqITSWosGqmhimT"

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# swagger configurations
config :api, :phoenix_swagger,
  swagger_files: %{
    "priv/static/swagger.json" => [
      # phoenix routes will be converted to swagger paths
      router: ApiWeb.Router,
      # (optional) endpoint config used to set host, port and https schemes.
      endpoint: ApiWeb.Endpoint
    ]
  }

# mailer configurations
config :api, Api.Mailer,
  adapter: Bamboo.SendGridAdapter,
  email_confirmation_base_url: System.get_env("EMAIL_CONFIRMATION_BASE_URL"),
  api_key: System.get_env("MAILER_API_KEY"),
  username: System.get_env("MAILER_USERNAME"),
  domain: System.get_env("MAILER_DOMAIN")

# Oban Configurations
config :api,
       Oban,
       repo: Data.Repo,
       crontab: false,
       plugins: [Oban.Plugins.Pruner],
       queues: [
         {Api.Worker, 5}
       ]

config :phoenix_swagger, json_library: Jason
# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
