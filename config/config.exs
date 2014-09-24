use Mix.Config

config :vestige, :storage_path, "/tmp/vestige"

config :phoenix, Vestige.Router,
  port: System.get_env("PORT"),
  ssl: false,
  static_assets: true,
  cookies: false,
  session_key: "_vestige_key",
  session_secret: "UEN1!RSBFJF71WRD0D69KSCCWDU1QJ2(@VJ0ZO5%9)+SR9O4YG!@C9B!8D*I0NOTF19VRG&BOHB$^3",
  catch_errors: true,
  debug_errors: false,
  error_controller: Vestige.PageController

config :phoenix, :code_reloader,
  enabled: false

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. Note, this must remain at the bottom of
# this file to properly merge your previous config entries.
import_config "#{Mix.env}.exs"
