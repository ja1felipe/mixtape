defmodule MixtapeWeb.CreateMixtape.Components do
  alias Phoenix.LiveView.JS
  use Phoenix.Component

  import MixtapeWeb.CoreComponents

  attr :artists, :list, required: true
  attr :id, :string, required: true
  attr :phx_hook, :string

  def artist_search_list(assigns) do
    ~H"""
    <div phx-hook={@phx_hook} id={@id} class="z-50 hidden">
      <%= if length(@artists) > 0 do %>
        <ul class="absolute flex flex-col border-2 border-slate-400 shadow-2xl shadow-slate-700 mt-2 rounded-sm w-full search-list overflow-hidden">
          <%= for artist <- @artists do %>
            <.artist_search_item artist={artist} />
          <% end %>
        </ul>
      <% end %>
    </div>
    """
  end

  attr :artist, :map, required: true

  def artist_search_item(assigns) do
    ~H"""
    <li
      phx-click={JS.push("select-artist", value: %{artist: @artist})}
      class="flex flex-row gap-2 bg-slate-950 opacity-95 hover:opacity-100 p-2 search-item hover:cursor-pointer"
    >
      <div class="flex bg-gray-700 rounded-md w-14 h-14 overflow-hidden">
        <%= if @artist["image"] do %>
          <img
            src={@artist["image"]}
            class="w-14 h-14 overflow-hidden object-cover"
            alt={@artist["name"]}
          />
        <% else %>
          <.icon class="m-auto self-center" name="hero-photo" />
        <% end %>
      </div>
      <p class="text-xl"><%= @artist["name"] %></p>
      <%= if @artist["selected"] do %>
        <span class="ml-auto w-8 h-8 text-primary transition-colors hero-check-circle remove-icon self-center" />
      <% else %>
        <span class="ml-auto w-8 h-8 add-icon hero-plus-circle self-center" name="hero-plus-circle" />
      <% end %>
    </li>
    """
  end

  attr :artists, :list, required: true
  attr :id, :string, required: true
  attr :target, :string, required: true

  def artist_list(assigns) do
    ~H"""
    <div id={@id}>
      <%= if length(@artists) > 0 do %>
        <ul class="flex flex-col w-full artists-list">
          <%= for artist <- @artists do %>
            <.artist_list_item target={@target} artist={artist} />
          <% end %>
        </ul>
      <% end %>
    </div>
    """
  end

  attr :artist, :map, required: true
  attr :target, :string, required: true

  def artist_list_item(assigns) do
    ~H"""
    <li class="flex flex-row items-center gap-8 border-slate-400 opacity-90 hover:opacity-100 p-2 border">
      <div class="flex rounded-md w-10 h-10 overflow-hidden">
        <%= if @artist["image"] do %>
          <img
            src={@artist["image"]}
            class="w-10 h-10 overflow-hidden object-cover"
            alt={@artist["name"]}
          />
        <% else %>
          <.icon class="m-auto self-center" name="hero-photo" />
        <% end %>
      </div>
      <p class="text-xl"><%= @artist["name"] %></p>
      <span
        phx-target={@target}
        phx-click={JS.push("select-artist", value: %{artist: @artist})}
        class="ml-auto w-8 h-8 hover:text-red-600 hover:cursor-pointer add-icon hero-x-mark self-center"
      />
    </li>
    """
  end
end
