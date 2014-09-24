use Mix.Config

config :phoenix, Vestige.Router,
  port: System.get_env("PORT") || 4001,
  ssl: false,
  cookies: true,
  session_key: "_vestige_key",
  session_secret: "UEN1!RSBFJF71WRD0D69KSCCWDU1QJ2(@VJ0ZO5%9)+SR9O4YG!@C9B!8D*I0NOTF19VRG&BOHB$^3"

config :phoenix, :code_reloader,
  enabled: true

config :logger, :console,
  level: :debug


