import Config

config :appsignal, :config,
  otp_app: :todo_lv,
  name: System.get_env("APP_SIGNAL_APP_NAME"),
  push_api_key: System.get_env("APP_SIGNAL_PUSH_API_KEY"),
  env: Mix.env()
