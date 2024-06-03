defmodule MixtapeWeb.LandingLive do
  use MixtapeWeb, :live_view
  import Dotenvy

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
