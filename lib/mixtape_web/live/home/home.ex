defmodule MixtapeWeb.HomeLive do
  use MixtapeWeb, :live_view

  def mount(_params, session, socket) do
    IO.inspect(session)
    IO.inspect(socket)
    IO.inspect(DateTime.utc_now())
    {:ok, socket}
  end
end
