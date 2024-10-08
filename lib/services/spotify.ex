defmodule Services.SpotifyAPI do
  use Tesla

  @authorization_url "https://accounts.spotify.com"

  @api_url "https://api.spotify.com/v1"

  @middleware [
    {Tesla.Middleware.BaseUrl, @api_url},
    {Tesla.Middleware.Headers, [{"Content-Type", "application/json"}]},
    Tesla.Middleware.JSON
  ]

  def login(code) do
    scope = "playlist-modify-private playlist-modify-public user-read-email user-read-private"

    url =
      Tesla.build_url(@authorization_url <> "/authorize",
        response_type: "code",
        client_id: Application.get_env(:mixtape, :spotify_client_id),
        scope: scope,
        redirect_uri: "http://localhost:4000/webhook",
        code_challenge_method: "S256",
        code_challenge: code
      )

    url
  end

  def token(code, verifier) do
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
      redirect_uri: "http://localhost:4000/webhook",
      code_verifier: verifier,
      client_id: Application.get_env(:mixtape, :spotify_client_id)
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

  defp generate_authorization_header do
    client_id = Application.get_env(:mixtape, :spotify_client_id)
    client_secret = Application.get_env(:mixtape, :spotify_client_secret)

    auth_string = "#{client_id}:#{client_secret}"
    encoded_auth_string = Base.encode64(auth_string)

    "Basic #{encoded_auth_string}"
  end

  def get_profile(access_token) do
    build_client(access_token)
    |> get("/me")
  end

  def search(access_token, search, page \\ 0) do
    limit = 5

    build_client(access_token)
    |> get("/search",
      query: [q: search, type: "artist", limit: limit, market: "BR", offset: page * limit]
    )
  end

  def get_artists_top_tracks(access_token, artist_id) do
    build_client(access_token)
    |> get("/artists/#{artist_id}/top-tracks", query: [market: "BR"])
  end

  def create_playlist(access_token, user_id, name) do
    build_client(access_token)
    |> post("/users/#{user_id}/playlists", %{
      name: name,
      public: false,
      collaborative: false,
      description: "Essa delicinha foi criada pelo Mixtape"
    })
  end

  def fill_playlist(access_token, playlist_id, tracks_uris) do
    build_client(access_token)
    |> post("/playlists/#{playlist_id}/tracks", %{
      uris: tracks_uris
    })
  end

  defp build_client(access_token) do
    middleware =
      [
        {Tesla.Middleware.Headers, [{"Authorization", "Bearer #{access_token}"}]}
      ] ++ @middleware

    Tesla.client(middleware)
  end
end
