defmodule MixtapeWeb.WebhookController do
  alias Services.SpotifyAPI
  use MixtapeWeb, :controller

  def webhook(conn, params) do
    code = params["code"]

    case SpotifyAPI.token(code) do
      {:ok, response} ->
        conn
        |> put_session(:access_token, response.body["access_token"])
        |> put_session(:refresh_token, response.body["refresh_token"])
        |> redirect(to: "/home")

      {:error, response} ->
        IO.inspect(response)

        conn
        |> redirect(to: "/")
    end
  end
end
