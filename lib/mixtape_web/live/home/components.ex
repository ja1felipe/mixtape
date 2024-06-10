defmodule MixtapeWeb.Home.Components do
  use Phoenix.Component

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
end
