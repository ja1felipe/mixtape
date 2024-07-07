defmodule MixtapeWeb.Layouts do
  @moduledoc """
  This module holds different layouts used by your application.

  See the `layouts` directory for all templates available.
  The "root" layout is a skeleton rendered as part of the
  application router. The "app" layout is set as the default
  layout on both `use MixtapeWeb, :controller` and
  `use MixtapeWeb, :live_view`.
  """
  use MixtapeWeb, :html
  import MixtapeWeb.Components
  alias Phoenix.LiveView.JS

  embed_templates "layouts/*"

  def toggle_mixtapes(js \\ %JS{}) do
    js
    |> JS.toggle(
      to: "#mixtapes-menu",
      in:
        {"transition ease-out duration-90", "transform opacity-0 translate-y-[-10%]",
         "transform opacity-100 translate-y-0"},
      out: {"transition ease-out duration-200", "transform opacity-100", "transform opacity-0"},
      display: "flex"
    )
    |> JS.toggle_class("hero-chevron-right", to: "#mixtapes-menu-arrow")
    |> JS.toggle_class("hero-chevron-down", to: "#mixtapes-menu-arrow")
  end
end
