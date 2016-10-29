# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :maru, ZmqBroker.Api,
    http: [port: 30050]

config :ex_json_schema,
  :remote_schema_resolver,
  fn url -> HTTPoison.get!(url).body |> Poison.decode! end

config :zmq_broker,
  events_port_sub: 30051,
  events_port_pub: 30052,
  initial_port: 31000

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure for your application as:
#
#     config :zmq_broker, key: :value
#
# And access this configuration in your application as:
#
#     Application.get_env(:zmq_broker, :key)
#
# Or configure a 3rd-party app:
#
#     config :logger, level: :info
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env}.exs"
