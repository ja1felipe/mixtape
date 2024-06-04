defmodule Services.SpotifyAPI do
  use Tesla

  plug Tesla.Middleware.BaseUrl, ""
  plug Tesla.Middleware.Headers, []
  plug Tesla.Middleware.JSON
end
