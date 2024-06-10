defmodule MixtapeWeb.SpotifyLoginController do
  alias Services.SpotifyAPI
  alias MixtapeWeb.UserAuth
  use MixtapeWeb, :controller

  def webhook(conn, %{"code" => code}) do
    UserAuth.spotify_login(conn, code)
  end

  def login(conn, _params) do
    verifier =
      Utils.generate_random_string(64)

    code_challenge =
      verifier
      |> Utils.sha256()
      |> Utils.base64encode()

    url = SpotifyAPI.login(code_challenge)

    conn
    |> put_session(:verifier, verifier)
    |> redirect(external: url)
  end
end
