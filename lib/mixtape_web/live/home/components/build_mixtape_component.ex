defmodule MixtapeWeb.Home.BuildMixtapeComponent do
  use Phoenix.LiveComponent

  import MixtapeWeb.CoreComponents
  import MixtapeWeb.Home.Components

  def mount(socket) do
    form =
      %{}
      |> Map.put("mixtape_size", 10)
      |> Map.put("select", false)

    socket =
      socket
      |> assign(form: to_form(form))

    {:ok, socket}
  end

  def update(assing, socket) do
    %{:value => value} = socket.assigns.form["mixtape_size"]

    IO.inspect(value)

    value =
      if value < length(assing.artists) do
        length(assing.artists)
      else
        value
      end

    form =
      %{}
      |> Map.put("mixtape_size", value)

    socket =
      socket
      |> assign(form: to_form(form))
      |> assign(:artists, assing.artists)

    {:ok, socket}
  end

  def handle_event("select-artist", %{"artist" => just_selected}, socket) do
    send(self(), {:select_artist, just_selected})

    {:noreply, socket}
  end

  attr :artists, :list, default: []

  def render(assigns) do
    ~H"""
    <div class="z-3 overflow-auto mt-3">
      <.form class="max-h-full flex flex-col gap-3" target={@myself} id="form" for={@form}>
        <div class="flex gap-4 items-center">
          <.input
            label="Tamanho da mixtape"
            field={@form[:mixtape_size]}
            type="number"
            width="w-[65px]"
            direction="row"
            id="mixtape_size"
            min="10"
          />
          <.input
            label="Incluir Top 10"
            field={@form[:select]}
            type="checkbox"
            reverse={true}
            id="top10"
          />
        </div>
        <.artist_list target={@myself} id="artists_list" artists={@artists} />
        <div class="self-end">
          <div class="group cursor-pointer relative inline-block text-center">
            <.button class="generate-button">
              <span class="hero-forward-solid text-slate-950" />
            </.button>
            <span class="opacity-0 w-28 bg-slate-950 text-white text-center text-md rounded-md mr-4 py-2 absolute z-10 group-hover:opacity-100 right-full top-1/2 -translate-y-1/2 px-3 pointer-events-none">
              Gerar Mixtape
            </span>
          </div>
        </div>
      </.form>
    </div>
    """
  end
end
