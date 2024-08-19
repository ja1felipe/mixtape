defmodule MixtapeWeb.UpdateMixtape.Components do
  use Phoenix.Component
  import MixtapeWeb.CoreComponents

  def tracks_list(assigns) do
    ~H"""
    <div id={@id}>
      <%= if length(@tracks) > 0 do %>
        <ul class="flex flex-col w-full tracks-list">
          <%= for track <- @tracks do %>
            <.track_list_item track={track} />
          <% end %>
        </ul>
      <% end %>
    </div>
    """
  end

  attr :track, :map, required: true

  def track_list_item(assigns) do
    ~H"""
    <li class="flex flex-row items-center gap-8 border-slate-400 opacity-90 hover:opacity-100 p-2 border">
      <div class="flex rounded-md w-10 h-10 overflow-hidden">
        <%= if @track["image"] do %>
          <img
            src={@track["image"]}
            class="w-10 h-10 overflow-hidden object-cover"
            alt={@track["track_name"]}
          />
        <% else %>
          <.icon class="m-auto self-center" name="hero-photo" />
        <% end %>
      </div>
      <p class="text-xl"><%= @track["track_name"] %></p>
      <span class="ml-auto w-8 h-8 hover:text-red-600 hover:cursor-pointer add-icon hero-x-mark self-center" />
    </li>
    """
  end
end
