defmodule MixtapeWeb.HomeLive do
  alias Services.SpotifyAPI
  use MixtapeWeb, :live_view
  import MixtapeWeb.Home.Components
  import Phoenix.Component
  alias MixtapeWeb.Home.BuildMixtapeComponent

  def mount(_params, _session, socket) do
    form =
      %{}
      |> Map.put("search", nil)

    socket =
      socket
      |> assign(form: to_form(form))
      |> assign(:loading, false)
      |> assign(:selected_artists, [
        %{
          "id" => "29QKtXMaVczUBDiI3aPBWS",
          "image" => "https://i.scdn.co/image/ab6761610000f178f11fcf161bed1f72afb30a21",
          "name" => "FBC",
          "selected" => true,
          "uri" => "spotify:artist:29QKtXMaVczUBDiI3aPBWS"
        }
      ])
      |> assign(:artists, [
        %{
          "id" => "29QKtXMaVczUBDiI3aPBWS",
          "name" => "FBC",
          "image" => "https://i.scdn.co/image/ab6761610000f178f11fcf161bed1f72afb30a21",
          "uri" => "spotify:artist:29QKtXMaVczUBDiI3aPBWS",
          "selected" => true
        },
        %{
          "id" => "6aCbXH85qN6xo54C7atSMx",
          "name" => "Black Alien",
          "image" => "https://i.scdn.co/image/ab6761610000f178ba2786969b06c231b04a3f80",
          "uri" => "spotify:artist:6aCbXH85qN6xo54C7atSMx",
          "selected" => false
        },
        %{
          "id" => "5Znx4PG5UsUitigaJnmZX3",
          "name" => "Flora Matos",
          "image" => "https://i.scdn.co/image/ab6761610000f1787f25349a142a2a41fc51af7b",
          "uri" => "spotify:artist:5Znx4PG5UsUitigaJnmZX3",
          "selected" => false
        },
        %{
          "id" => "25iPyUnAhtlrcpkscGuXgm",
          "name" => "Fbc",
          "image" => nil,
          "uri" => "spotify:artist:25iPyUnAhtlrcpkscGuXgm",
          "selected" => false
        },
        %{
          "id" => "38kjd8LvypN0JqxHcXYvqh",
          "name" => "FBCORUJA",
          "image" => nil,
          "uri" => "spotify:artist:38kjd8LvypN0JqxHcXYvqh",
          "selected" => false
        }
      ])

    {:ok, socket}
  end

  def handle_info({:generate_mixtape, size}, socket) do
    %{:current_user => user, :artists => artists} = socket.assigns

    how_many_of_each =
      Float.ceil(size / length(artists))
      |> round()

    tracks =
      artists
      |> Enum.map(fn artist -> artist["id"] end)
      |> Enum.map(&Task.async(fn -> SpotifyAPI.get_artists_top_tracks(user.access_token, &1) end))
      |> Enum.map(&Task.await/1)
      |> Enum.map(&get_tracks/1)
      |> Enum.flat_map(&take_random_items(&1, how_many_of_each))
      |> take_random_items(size)

    IO.inspect(tracks)
    {:noreply, socket}
  end

  def handle_info({:select_artist, just_selected}, socket) do
    handle_select_artists(just_selected, socket, false)
  end

  def handle_event("select-artist", %{"artist" => just_selected}, socket) do
    handle_select_artists(just_selected, socket, true)
  end

  def handle_event("search", %{"search" => search}, socket) do
    user = socket.assigns.current_user
    selected_artists = socket.assigns.selected_artists

    socket =
      socket
      |> assign(:loading, true)
      |> start_async(:get_artists, fn ->
        fech_artists(user.access_token, search, selected_artists)
      end)

    {:noreply, socket}
  end

  def handle_async(:get_artists, {:ok, res}, socket) do
    socket =
      socket
      |> assign(:loading, false)
      |> assign(:artists, res)
      |> push_event("update-artists", %{refresh: true})

    {:noreply, socket}
  end

  def handle_async(:get_artists, {:error, reason}, socket) do
    IO.inspect(reason)
    {:noreply, assign(socket, :loading, false)}
  end

  defp fech_artists(access_token, search, selected_artists) do
    case SpotifyAPI.search(access_token, search) do
      {:ok, response} ->
        if response.status == 200 do
          result =
            response.body
            |> Map.get("artists", %{})
            |> Map.get("items", [])
            |> Enum.map(fn item ->
              %{
                "name" => Map.get(item, "name"),
                "id" => Map.get(item, "id"),
                "image" =>
                  case item["images"] do
                    [] -> nil
                    images -> Enum.min_by(images, & &1["height"])["url"]
                  end,
                "uri" => Map.get(item, "uri"),
                "selected" =>
                  Enum.any?(selected_artists, fn a -> a["id"] == Map.get(item, "id") end)
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

  defp handle_select_artists(just_selected, socket, refresh) do
    selected_artists = socket.assigns.selected_artists
    artists = socket.assigns.artists

    has_artists =
      selected_artists
      |> Enum.find(fn a -> a["id"] == just_selected["id"] end)

    selected_artists =
      if has_artists do
        Enum.reject(selected_artists, fn a -> a["id"] == just_selected["id"] end)
      else
        [just_selected | selected_artists]
      end
      |> Enum.reverse()

    artists_updated =
      Enum.map(artists, fn artist ->
        if artist["id"] == just_selected["id"] do
          Map.update!(artist, "selected", fn selected -> !selected end)
        else
          artist
        end
      end)

    socket =
      socket
      |> assign(:selected_artists, selected_artists)
      |> assign(:artists, artists_updated)
      |> push_event("update-artists", %{refresh: refresh})

    {:noreply, socket}
  end

  defp take_random_items(list, count) do
    list
    |> Enum.shuffle()
    |> Enum.take(count)
  end

  defp get_tracks({:ok, response}) do
    tracks = response.body["tracks"]

    tracks =
      tracks
      |> Enum.map(fn track ->
        %{
          "id" => track["id"],
          "track_name" => track["name"],
          "image" =>
            case track["album"]["images"] do
              [] -> nil
              images -> Enum.min_by(images, & &1["height"])["url"]
            end
        }
      end)

    tracks
  end
end
