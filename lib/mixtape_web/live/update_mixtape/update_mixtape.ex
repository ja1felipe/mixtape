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

  defp create_spotify_playlist(access_token, user_id, name, tracks_uris) do
    with {:ok, response} <- SpotifyAPI.create_playlist(access_token, user_id, name),
         201 <- response.status,
         playlist_id <- response.body["id"],
         {:ok, _add_tracks_response} <-
           SpotifyAPI.fill_playlist(access_token, playlist_id, tracks_uris) do
      # TODO - Save playlist_id in the mixtape and change the status to "published"
      {:ok, playlist_id}
    else
      {:error, reason} -> {:error, reason}
      _ -> {:error, "Failed to create playlist or add tracks"}
    end
  end
end
