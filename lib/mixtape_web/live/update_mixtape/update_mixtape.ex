defmodule MixtapeWeb.UpdateMixtapeLive do
  use MixtapeWeb, :live_view

  def mount(params, session, socket) do
    IO.inspect(params)
    IO.inspect(session)
    IO.inspect(socket.assigns)
    {:ok, socket}
  end
end
