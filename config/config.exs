# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :noteblock,
  ecto_repos: [Noteblock.Repo]

# Configures the endpoint
config :noteblock, Noteblock.Endpoint,
  url: [host: "127.0.0.1"],
  secret_key_base: "WeGxnzHoueDwIonR/JZvNydj90CSe9H8hVW/8uYCGixRiw+P7jbkupzFc3Dducwn",
  render_errors: [view: Noteblock.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Noteblock.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
