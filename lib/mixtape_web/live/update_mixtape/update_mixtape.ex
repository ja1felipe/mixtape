defmodule MixtapeWeb.UpdateMixtapeLive do
  use MixtapeWeb, :live_view
  import MixtapeWeb.UpdateMixtape.Components
  alias Mixtape.Mixtapes

  def mount(params, _session, socket) do
    %{"id" => id} = params
    mixtape = Mixtapes.get_by_id(id)
    form = %{"name" => mixtape.name}

    socket =
      socket
      |> assign(:mixtape, mixtape)
      |> assign(:form, to_form(form))

    {:ok, socket}
  end

  def handle_event("create-playlist", unsigned_params, socket) do
    IO.inspect(unsigned_params)
    {:noreply, socket}
  end
end
