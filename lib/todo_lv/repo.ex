defmodule TodoLv.Repo do
  use Ecto.Repo,
    otp_app: :todo_lv,
    adapter: Ecto.Adapters.Postgres
end
