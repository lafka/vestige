use Mix.Config

# NOTE: To get SSL working, you will need to set:
#
#     ssl: true,
#     keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
#     certfile: System.get_env("SOME_APP_SSL_CERT_PATH"),
#
# Where those two env variables point to a file on disk
# for the key and cert

config :phoenix, Vestige.Router,
  port: System.get_env("PORT") || 80,
  ssl: false,
  host: "vestige.service.consul",
  cookies: false

config :logger, :console,
  level: :info,
  metadata: [:request_id]

