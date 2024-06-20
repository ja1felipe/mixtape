defmodule MixtapeWeb.Home.BuildMixtapeComponent do
  use Phoenix.LiveComponent
  import MixtapeWeb.Home.Components

  def handle_event("select-artist", %{"artist" => just_selected}, socket) do
    send(self(), {:select_artist, just_selected})

    {:noreply, socket}
  end

  attr :artists, :list, default: []

  def render(assigns) do
    ~H"""
    <div class="z-3">
      <.artist_list target={@myself} id="artists_list" artists={@artists} />
    </div>
    """
  end
end
