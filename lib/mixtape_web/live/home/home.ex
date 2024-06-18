defmodule MixtapeWeb.HomeLive do
  alias Services.SpotifyAPI
  use MixtapeWeb, :live_view
  import MixtapeWeb.Home.Components
  import Phoenix.Component

  def mount(_params, _session, socket) do
    form =
      %{}
      |> Map.put("search", nil)

    socket =
      socket
      |> assign(form: to_form(form))
      |> assign(:loading, false)
      |> assign(:artists, [
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
          id: "5Znx4PG5UsUitigaJnmZX3",
          name: "Flora Matos",
          image: "https://i.scdn.co/image/ab6761610000f1787f25349a142a2a41fc51af7b",
          uri: "spotify:artist:5Znx4PG5UsUitigaJnmZX3"
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
      ])

    {:ok, socket}
  end

  def handle_event("search", %{"search" => search}, socket) do
    user = socket.assigns.current_user

    socket =
      socket
      |> assign(:loading, true)
      |> start_async(:get_artists, fn -> fech_artists(user.access_token, search) end)

    {:noreply, socket}
  end

  def handle_async(:get_artists, {:ok, res}, socket) do
    socket =
      socket
      |> assign(:loading, false)
      |> assign(:artists, res)

    {:noreply, socket}
  end

  def handle_async(:get_artists, {:error, reason}, socket) do
    IO.inspect(reason)

    {:noreply, assign(socket, :loading, false)}
  end

  defp fech_artists(access_token, search) do
    case SpotifyAPI.search(access_token, search) do
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

          result.items
        else
          []
        end

      {:error, response} ->
        IO.inspect(response)
        :error
    end
  end
end
