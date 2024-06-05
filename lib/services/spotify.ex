defmodule Services.SpotifyAPI do
  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://accounts.spotify.com"
  plug Tesla.Middleware.Headers, [{"Content-Type", "application/json"}]
  plug Tesla.Middleware.JSON

  def login() do
    scope = "playlist-modify-private playlist-modify-public user-read-email"

    url =
      Tesla.build_url("https://accounts.spotify.com/authorize",
        response_type: "code",
        client_id: Application.get_env(:mixtape, :spotify_client_id),
        scope: scope,
        redirect_uri: "http://localhost:4000/webhook",
        state: Utils.generateRandomString(16)
      )

    url
  end

  def token(code) do
    formClient =
      Tesla.client([
        {Tesla.Middleware.BaseUrl, "https://accounts.spotify.com"},
        {Tesla.Middleware.Headers,
         [
           {"Content-Type", "application/x-www-form-urlencoded"},
           {"Authorization", generate_authorization_header()}
         ]},
        Tesla.Middleware.FormUrlencoded
      ])

    post(formClient, "/api/token ", %{
      grant_type: "authorization_code",
      code: code,
      redirect_uri: "http://localhost:4000/webhook"
    })
  end

  defp generate_authorization_header do
    client_id = Application.get_env(:mixtape, :spotify_client_id)
    client_secret = Application.get_env(:mixtape, :spotify_client_secret)

    auth_string = "#{client_id}:#{client_secret}"
    encoded_auth_string = Base.encode64(auth_string)

    "Authorization: Basic #{encoded_auth_string}"
  end
end
