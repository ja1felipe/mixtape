defmodule MixtapeWeb.LandingLive do
  alias Services.SpotifyAPI
  use MixtapeWeb, :live_view

  def mount(_params, session, socket) do
    IO.inspect(session)

    {:ok, socket}
  end

  def handle_event("login-spotify", _params, socket) do
    {:noreply, redirect(socket, external: SpotifyAPI.login())}
  end
end
