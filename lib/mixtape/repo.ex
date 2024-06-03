defmodule Mixtape.Repo do
  use Ecto.Repo,
    otp_app: :mixtape,
    adapter: Ecto.Adapters.Postgres
end
