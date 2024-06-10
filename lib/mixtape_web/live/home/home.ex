defmodule MixtapeWeb.HomeLive do
  use MixtapeWeb, :live_view
  import MixtapeWeb.Home.Components

  def mount(_params, session, socket) do
    IO.inspect(session)
    IO.inspect(socket)
    IO.inspect(DateTime.utc_now())

    form =
      %{}
      |> Map.put("search", nil)

    socket =
      socket
      |> assign(form: to_form(form))

    {:ok, socket}
  end

  def handle_event("search", %{"search" => search}, socket) do
    IO.inspect(search)

    {:noreply, socket}
  end
end
