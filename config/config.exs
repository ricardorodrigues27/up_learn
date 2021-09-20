# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :up_learn,
  ecto_repos: [UpLearn.Repo]

# Configures the endpoint
config :up_learn, UpLearnWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "KrUIomITNEUZPRulLaS1xkezpHFRmAFpPZyMNJ1dKqPzlhjCtMrJyQmrkHVKCIH1",
  render_errors: [view: UpLearnWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: UpLearn.PubSub,
  live_view: [signing_salt: "hSz4I6/I"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :up_learn, UpLearn.WebScrapper.Fetcher, adapter: UpLearn.WebScrapper.Fetcher.Crawly

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
