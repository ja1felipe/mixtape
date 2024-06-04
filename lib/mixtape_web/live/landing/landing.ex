defmodule MixtapeWeb.LandingLive do
  use MixtapeWeb, :live_view

  def mount(_params, _session, socket) do
    IO.puts("cu 2 #{Application.get_env(:mixtape, :spotify_client_id)}")

    {:ok, socket}
  end

  def handle_event("login-spotify", _params, socket) do
    {:noreply, socket}
  end
end
