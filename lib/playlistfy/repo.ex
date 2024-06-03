defmodule Playlistfy.Repo do
  use Ecto.Repo,
    otp_app: :playlistfy,
    adapter: Ecto.Adapters.Postgres
end
