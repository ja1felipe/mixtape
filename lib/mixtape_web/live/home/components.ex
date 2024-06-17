defmodule MixtapeWeb.Home.Components do
  use Phoenix.Component

  import MixtapeWeb.CoreComponents

  def empty_mixtapes(assigns) do
    ~H"""
    <ul class="flex mt-5 flex-col h-full gap-2">
      <li class="flex flex-row gap-2">
        <div class="w-16 h-16 bg-white opacity-10 rounded-sm"></div>
        <div class="grow flex flex-col gap-2">
          <div class="w-full h-4 bg-white opacity-10"></div>
          <div class="w-10/12 h-4 bg-white opacity-10"></div>
          <div class="w-8/12 h-4 bg-white opacity-10"></div>
        </div>
      </li>
      <hr class="opacity-60 border-primary" />
      <li class="flex flex-row gap-2">
        <div class="w-16 h-16 bg-white opacity-10 rounded-sm"></div>
        <div class="grow flex flex-col gap-2">
          <div class="w-full h-4 bg-white opacity-10"></div>
          <div class="w-10/12 h-4 bg-white opacity-10"></div>
          <div class="w-8/12 h-4 bg-white opacity-10"></div>
        </div>
      </li>
      <hr class="opacity-60 border-primary" />
      <li class="flex flex-row gap-2">
        <div class="w-16 h-16 bg-white opacity-10 rounded-sm"></div>
        <div class="grow flex flex-col gap-2">
          <div class="w-full h-4 bg-white opacity-10"></div>
          <div class="w-10/12 h-4 bg-white opacity-10"></div>
          <div class="w-8/12 h-4 bg-white opacity-10"></div>
        </div>
      </li>
    </ul>
    """
  end

  attr :artists, :list, required: true
  attr :id, :string, required: true
  attr :click_away, :string
  attr :hidden, :string, default: "true"

  def artist_search_list(assigns) do
    ~H"""
    <div phx-hook={@click_away} id={@id} class="hidden">
      <%= if length(@artists) > 0 do %>
        <ul class="search-list flex flex-col border border-slate-400 overflow-hidden mt-2 rounded-md absolute w-full">
          <%= for artist <- @artists do %>
            <.artist_card artist={artist} />
          <% end %>
        </ul>
      <% end %>
    </div>
    """
  end

  def artist_card(assigns) do
    ~H"""
    <li class="flex opacity-80 bg-slate-950 flex-row gap-2 p-2 hover:opacity-100 hover:cursor-pointer">
      <div class="w-14 h-14 overflow-hidden rounded-md flex bg-gray-700">
        <%= if @artist.image do %>
          <img src={@artist.image} class="w-14 h-14 object-cover overflow-hidden" alt={@artist.name} />
        <% else %>
          <.icon class="self-center m-auto" name="hero-photo" />
        <% end %>
      </div>
      <p class="text-xl"><%= @artist.name %></p>
      <.icon class="self-center ml-auto w-8 h-8 " name="hero-plus-circle" />
    </li>
    """
  end
end
