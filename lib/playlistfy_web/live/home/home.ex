defmodule PlaylistfyWeb.HomeLive do
  use PlaylistfyWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end