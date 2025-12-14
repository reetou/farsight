defmodule Farsight.Repo do
  use Ecto.Repo,
    otp_app: :farsight,
    adapter: Ecto.Adapters.Postgres
end
