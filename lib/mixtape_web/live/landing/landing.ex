defmodule MixtapeWeb.LandingLive do
  use MixtapeWeb, :live_view

  def mount(_params, _session, socket) do
    IO.puts("cu #{System.get_env("SPOTIFY_CLIENT_ID")}")
    {:ok, socket}
  end
end
