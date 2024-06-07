defmodule Services.SpotifyAPI do
  use Tesla

  @authorization_url "https://accounts.spotify.com"

  @api_url "https://api.spotify.com/v1"

  @middleware [
    {Tesla.Middleware.BaseUrl, @api_url},
    {Tesla.Middleware.Headers, [{"Content-Type", "application/json"}]},
    Tesla.Middleware.JSON
  ]

  def login() do
    scope = "playlist-modify-private playlist-modify-public user-read-email user-read-private"

    url =
      Tesla.build_url(@authorization_url <> "/authorize",
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
      Tesla.client(
        [
          {Tesla.Middleware.BaseUrl, @authorization_url},
          {Tesla.Middleware.Headers,
           [
             {"Content-Type", "application/x-www-form-urlencoded"},
             {"Authorization", generate_authorization_header()}
           ]},
          Tesla.Middleware.FormUrlencoded
        ] ++ @middleware
      )

    post(formClient, "/api/token", %{
      grant_type: "authorization_code",
      code: code,
      redirect_uri: "http://localhost:4000/webhook"
    })
  end

  def refresh_token(refresh_token) do
    formClient =
      Tesla.client(
        [
          {Tesla.Middleware.BaseUrl, @authorization_url},
          {Tesla.Middleware.Headers,
           [
             {"Content-Type", "application/x-www-form-urlencoded"},
             {"Authorization", generate_authorization_header()}
           ]},
          Tesla.Middleware.FormUrlencoded
        ] ++ @middleware
      )

    post(formClient, "/api/token", %{
      grant_type: "refresh_token",
      refresh_token: refresh_token,
      client_id: Application.get_env(:mixtape, :spotify_client_id)
    })
  end

  def get_profile(access_token) do
    middleware =
      [
        {Tesla.Middleware.Headers, [{"Authorization", "Bearer #{access_token}"}]}
      ] ++ @middleware

    client = Tesla.client(middleware)

    get(client, "/me")
  end

  defp generate_authorization_header do
    client_id = Application.get_env(:mixtape, :spotify_client_id)
    client_secret = Application.get_env(:mixtape, :spotify_client_secret)

    auth_string = "#{client_id}:#{client_secret}"
    encoded_auth_string = Base.encode64(auth_string)

    "Basic #{encoded_auth_string}"
  end
end
