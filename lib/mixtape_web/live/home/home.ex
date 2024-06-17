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
      |> assign(
        artists: [
          %{
            id: "29QKtXMaVczUBDiI3aPBWS",
            name: "FBC",
            image: "https://i.scdn.co/image/ab6761610000f178f11fcf161bed1f72afb30a21",
            uri: "spotify:artist:29QKtXMaVczUBDiI3aPBWS"
          },
          %{
            id: "6aCbXH85qN6xo54C7atSMx",
            name: "Black Alien",
            image: "https://i.scdn.co/image/ab6761610000f178ba2786969b06c231b04a3f80",
            uri: "spotify:artist:6aCbXH85qN6xo54C7atSMx"
          },
          %{
            id: "5JHYuwE2n7bleXMUsmtCW5",
            name: "BaianaSystem",
            image: "https://i.scdn.co/image/ab6761610000f178ac291f376ca791339f922209",
            uri: "spotify:artist:5JHYuwE2n7bleXMUsmtCW5"
          },
          %{
            id: "25iPyUnAhtlrcpkscGuXgm",
            name: "Fbc",
            image: nil,
            uri: "spotify:artist:25iPyUnAhtlrcpkscGuXgm"
          },
          %{
            id: "38kjd8LvypN0JqxHcXYvqh",
            name: "FBCORUJA",
            image: nil,
            uri: "spotify:artist:38kjd8LvypN0JqxHcXYvqh"
          }
        ]
      )

    {:ok, socket}
  end

  def handle_event("search", %{"search" => search}, socket) do
    user = socket.assigns.current_user

    case SpotifyAPI.search(user.access_token, search) do
      {:ok, response} ->
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
