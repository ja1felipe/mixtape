defmodule MixtapeWeb.UpdateMixtapeLive do
  use MixtapeWeb, :live_view
  import MixtapeWeb.UpdateMixtape.Components
  alias Mixtape.Mixtapes
  alias Services.SpotifyAPI

  def mount(params, _session, socket) do
    %{"id" => id} = params
    mixtape = Mixtapes.get_by_id(id)
    form = %{"name" => mixtape.name}

    socket =
      socket
      |> assign(:mixtape, mixtape)
      |> assign(:loading, false)
      |> assign(:form, to_form(form))

    {:ok, socket}
  end

  def handle_event("create-playlist", unsigned_params, socket) do
    %{current_user: user, mixtape: mixtape} = socket.assigns
    user_id = user.spotify_id
    %{"name" => name} = unsigned_params

    tracks_uris =
      mixtape.tracks
      |> Enum.map(& &1["uri"])

    socket =
      socket
      |> assign(:loading, true)
      |> start_async(:create_spotify_playlist, fn ->
        create_spotify_playlist(user.access_token, user_id, name, tracks_uris)
      end)

    {:noreply, socket}
  end

  def handle_async(:create_spotify_playlist, {:ok, playlist}, socket) do
    %{:mixtape => mixtape} = socket.assigns

    Mixtapes.update_mixtape(mixtape.id, %{
      status: "published",
      spotify_playlist_id: playlist.id,
      name: playlist.name
    })

    socket =
      socket
      |> assign(:loading, false)

    {:noreply, socket}
  end

  def handle_async(:create_spotify_playlist, {:error, reason}, socket) do
    socket =
      socket
      |> assign(:loading, false)
      |> assign(:error, reason)

    IO.inspect("Error on create spotify playlist: #{reason}")

    {:noreply, socket}
  end

  defp create_spotify_playlist(access_token, user_id, name, tracks_uris) do
    with {:ok, response} <- SpotifyAPI.create_playlist(access_token, user_id, name),
         201 <- response.status,
         playlist_id <- response.body["id"],
         playlist_name <- response.body["name"],
         {:ok, _add_tracks_response} <-
           SpotifyAPI.fill_playlist(access_token, playlist_id, tracks_uris) do
      %{name: playlist_name, id: playlist_id}
    else
      {:error, reason} -> reason
      _ -> "Failed to create playlist or add tracks"
    end
  end
end
