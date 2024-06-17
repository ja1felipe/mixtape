defmodule MixtapeWeb.HomeLive do
  alias Services.SpotifyAPI
  use MixtapeWeb, :live_view
  import MixtapeWeb.Home.Components

  def mount(_params, _session, socket) do
    form =
      %{}
      |> Map.put("search", nil)

    socket =
      socket
      |> assign(form: to_form(form))
      |> assign(artists: [])

    {:ok, socket}
  end

  def handle_event("search", %{"search" => search}, socket) do
    user = socket.assigns.current_user

    case SpotifyAPI.search(user.access_token, search) do
      {:ok, response} ->
        IO.inspect(response)

        if response.status == 200 do
          result =
            response.body
            |> Map.get("artists", %{})
            |> Map.get("items", [])
            |> Enum.map(fn item ->
              %{
                name: Map.get(item, "name"),
                id: Map.get(item, "id"),
                image:
                  case item["images"] do
                    [] -> nil
                    images -> Enum.min_by(images, & &1["height"])["url"]
                  end,
                uri: Map.get(item, "uri")
              }
            end)
            |> (fn items -> %{items: items, next: Map.get(response.body["artists"], "next")} end).()

          socket =
            socket
            |> assign(artists: result.items)

          {:noreply, socket}
        else
          {:noreply, assign(socket, artists: [])}
        end

      {:error, response} ->
        IO.inspect(response)
        {:noreply, socket}
    end
  end
end
