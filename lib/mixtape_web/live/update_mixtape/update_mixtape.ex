defmodule MixtapeWeb.UpdateMixtapeLive do
  use MixtapeWeb, :live_view
  import MixtapeWeb.UpdateMixtape.Components
  alias Mixtape.Mixtapes

  def mount(params, _session, socket) do
    %{"id" => id} = params
    IO.inspect(id)
    mixtape = Mixtapes.get_by_id(id)
    IO.inspect(mixtape)
    form = %{name: mixtape.name}

    socket =
      socket
      |> assign(:mixtape, mixtape)
      |> assign(:form, to_form(form))

    {:ok, socket}
  end
end
