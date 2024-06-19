defmodule MixtapeWeb.Home.BuildMixtapeComponent do
  use Phoenix.LiveComponent

  attr :artists, :list, default: []

  def render(assigns) do
    ~H"""
    <ul>
      <li :for={artist <- @artists} :if={length(@artists) > 0}>
        <%= artist["name"] %>
      </li>
    </ul>
    """
  end
end
