defmodule Twostepsfromcode.Repo do
  use Ecto.Repo,
    otp_app: :twostepsfromcode,
    adapter: Ecto.Adapters.Postgres
end
