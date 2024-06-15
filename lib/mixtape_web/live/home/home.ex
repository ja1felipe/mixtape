defmodule MixtapeWeb.HomeLive do
  alias Services.SpotifyAPI
  use MixtapeWeb, :live_view
  import MixtapeWeb.Home.Components

  def mount(_params, session, socket) do
    IO.inspect(session)
    # IO.inspect(socket)
    IO.inspect(DateTime.utc_now())
    IO.puts("MOUNT HOME")
    if !connected?(socket), do: {:error, :unauthorized}

    form =
      %{}
      |> Map.put("search", nil)

    socket =
      socket
      |> assign(form: to_form(form))

    {:ok, socket}
  end

  def handle_event("search", %{"search" => search}, socket) do
    user = socket.assigns.current_user

    case SpotifyAPI.search(user.access_token, search) do
      {:ok, response} ->
        IO.inspect(response)

        result =
          response.body
          |> Map.get("artists", %{})
          |> Map.get("items", [])
          |> Enum.map(fn item ->
            %{
              artist_name: Map.get(item, "name"),
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

        IO.inspect(result)
        {:noreply, socket}

      {:error, response} ->
        IO.inspect(response)
        {:noreply, socket}
    end

    {:noreply, socket}
  end
end
