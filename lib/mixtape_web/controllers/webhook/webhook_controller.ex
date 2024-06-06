defmodule MixtapeWeb.WebhookController do
  alias MixtapeWeb.UserAuth
  use MixtapeWeb, :controller

  def webhook(conn, params) do
    code = params["code"]

    UserAuth.spotify_login(conn, code)
  end
end
