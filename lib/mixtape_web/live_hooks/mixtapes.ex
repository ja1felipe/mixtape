defmodule MixtapeWeb.LiveHooks.Mixtapes do
  import Phoenix.Component
  alias Mixtape.Mixtapes

  def on_mount(:fetch_user_mixtapes, _params, _session, socket) do
    %{:current_user => user} = socket.assigns
    mixtapes = Mixtapes.get_mixtapes_by_user_id(user.id)
    IO.inspect(mixtapes)

    socket =
      socket
      |> assign(:user_mixtapes, mixtapes)

    {:cont, socket}
  end
end
