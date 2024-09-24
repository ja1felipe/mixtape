defmodule MixtapeWeb.ListMixtapes do
  use Phoenix.LiveComponent
  alias Phoenix.LiveView.JS
  alias Mixtape.Mixtapes

  def mount(socket) do
    {:ok, socket}
  end

  def update(assigns, socket) do
    %{:current_user => user} = assigns
    mixtapes = Mixtapes.get_mixtapes_by_user_id(user.id)

    socket =
      socket
      |> stream(:mixtapes, mixtapes)

    {:ok, assign(socket, assigns)}
  end

  attr :class, :string, default: ""
  attr :id, :string
  attr :current_user, :map

  def render(assigns) do
    ~H"""
    <ul id={@id} class={["flex flex-col gap-2 mt-5 h-full"]}>
      <li
        :for={{id, mixtape} <- @streams.mixtapes}
        class="flex flex-row gap-2 cursor-pointer opacity-85 hover:opacity-100"
        id={id}
        phx-click={JS.navigate("/wrapup/#{mixtape.id}")}
      >
        <div class="bg-white rounded-sm w-[4.5rem] h-[4.5rem] flex items-center justify-center bg-opacity-10">
          <span class="hero-wrench-screwdriver-solid bg-white" />
        </div>
        <div class="flex flex-col gap-2 grow">
          <span>
            <%= mixtape.name || "Me acaba neném" %>
          </span>
          <div :if={mixtape.status == :unpublished} class="flex flex-col gap-0.5">
            <span class="text-red-600 text-sm">
              não finalizada
            </span>
            <span class="text-xs text-red-700">(me acaba bb)</span>
          </div>
        </div>
      </li>
    </ul>
    """
  end
end
