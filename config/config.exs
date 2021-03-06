# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :avalon_backend, AvalonBackend.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "hxHLPRI89Qz5NVfbZVQ5u0Fgw/yXziL9yyMT6qdayRhaMjMhebVdcZr6PYacyXDx",
  render_errors: [view: AvalonBackend.ErrorView, accepts: ~w(html json)],
  pubsub: [name: AvalonBackend.PubSub,
           adapter: Phoenix.PubSub.PG2],
  fsm_server_url: "localhost:4001"

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
