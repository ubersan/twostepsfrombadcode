# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :twostepsfromcode,
  ecto_repos: [Twostepsfromcode.Repo]

# Configures the endpoint
config :twostepsfromcode, TwostepsfromcodeWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "g+ia0T6tUrxldZKL0wp1rCoKrdIC99SiMP8x//2Pn6QSsFv7Kv6v1YFWPwLShsgz",
  render_errors: [view: TwostepsfromcodeWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Twostepsfromcode.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
