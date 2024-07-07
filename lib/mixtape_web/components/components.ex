defmodule MixtapeWeb.Components do
  use Phoenix.Component
  alias Phoenix.LiveView.JS

  attr :class, :string
  attr :id, :string

  def empty_mixtapes_list(assigns) do
    ~H"""
    <ul id={@id} class={["flex flex-col gap-2 mt-5 h-full", @class]}>
      <li class="flex flex-row gap-2">
        <div class="bg-white opacity-10 rounded-sm w-16 h-16"></div>
        <div class="flex flex-col gap-2 grow">
          <div class="bg-white opacity-10 w-full h-4"></div>
          <div class="bg-white opacity-10 w-10/12 h-4"></div>
          <div class="bg-white opacity-10 w-8/12 h-4"></div>
        </div>
      </li>
      <hr class="border-primary opacity-60" />
      <li class="flex flex-row gap-2">
        <div class="bg-white opacity-10 rounded-sm w-16 h-16"></div>
        <div class="flex flex-col gap-2 grow">
          <div class="bg-white opacity-10 w-full h-4"></div>
          <div class="bg-white opacity-10 w-10/12 h-4"></div>
          <div class="bg-white opacity-10 w-8/12 h-4"></div>
        </div>
      </li>
      <hr class="border-primary opacity-60" />
      <li class="flex flex-row gap-2">
        <div class="bg-white opacity-10 rounded-sm w-[4.5rem] h-[4.5rem]"></div>
        <div class="flex flex-col gap-2 grow">
          <div class="bg-white opacity-10 w-full h-4"></div>
          <div class="bg-white opacity-10 w-10/12 h-4"></div>
          <div class="bg-white opacity-10 w-8/12 h-4"></div>
        </div>
      </li>
    </ul>
    """
  end

  attr :class, :string, default: ""
  attr :id, :string
  attr :mixtapes, :list

  def mixtapes_list(assigns) do
    ~H"""
    <ul id={@id} class={["flex flex-col gap-2 mt-5 h-full", @class]}>
      <li
        :for={{mixtape, index} <- Enum.with_index(@mixtapes)}
        class="flex flex-row gap-2 cursor-pointer opacity-85 hover:opacity-100"
        phx-click={JS.navigate("/wrapup/#{mixtape.id}")}
      >
        <div class="bg-white rounded-sm w-[4.5rem] h-[4.5rem] flex items-center justify-center bg-opacity-10">
          <span class="hero-wrench-screwdriver-solid bg-white" />
        </div>
        <div class="flex flex-col gap-2 grow">
          <span>
            <%= mixtape.name || "Mixtape ##{index}" %>
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
