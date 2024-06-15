defmodule MixtapeWeb.UserAuth do
  use MixtapeWeb, :verified_routes

  import Plug.Conn
  import Phoenix.Controller

  alias Services.SpotifyAPI
  alias Mixtape.Users

  require Logger
  # Make the remember me cookie valid for 60 days.
  # If you want bump or reduce this value, also change
  # the token expiry itself in UserToken.
  @remember_me_cookie "_mixtape_web_user_remember_me"

  def spotify_login(conn, code, _params \\ %{}) do
    verifier = get_session(conn, :verifier)

    case SpotifyAPI.token(code, verifier) do
      {:ok, response} ->
        expiration = DateTime.utc_now() |> DateTime.add(60, :second)

        response.body["access_token"]
        |> get_spotify_user()
        |> create_or_update_user(response.body["access_token"], response.body["refresh_token"])

        token = %{
          access_token: response.body["access_token"],
          timeout: expiration,
          refresh_token: response.body["refresh_token"]
        }

        conn
        |> put_token_in_session(token)
        |> clear_flash()
        |> redirect(to: "/home")

      {:error, response} ->
        IO.inspect(response)

        conn
        |> redirect(to: "/")
    end
  end

  defp get_spotify_user(token) do
    case SpotifyAPI.get_profile(token) do
      {:ok, response} ->
        Logger.info("Spotify user: #{inspect(response)}")

        response.body

      {:error, response} ->
        IO.inspect(response)
        nil
    end
  end

  defp create_or_update_user(%{} = spotify_user, access_token, refresh_token) do
    case Users.get_user_by_spotify_id(spotify_user["id"]) do
      nil ->
        Users.register_user(%{
          "spotify_id" => spotify_user["id"],
          "email" => spotify_user["email"],
          "name" => spotify_user["display_name"],
          "access_token" => access_token,
          "refresh_token" => refresh_token
        })

      user ->
        user
        |> Users.update_user_access_token(access_token, refresh_token)
    end
  end

  # This function renews the session ID and erases the whole
  # session to avoid fixation attacks. If there is any data
  # in the session you may want to preserve after log in/log out,
  # you must explicitly fetch the session data before clearing
  # and then immediately set it after clearing, for example:
  #
  #     defp renew_session(conn) do
  #       preferred_locale = get_session(conn, :preferred_locale)
  #
  #       conn
  #       |> configure_session(renew: true)
  #       |> clear_session()
  #       |> put_session(:preferred_locale, preferred_locale)
  #     end
  #
  defp renew_session(conn) do
    delete_csrf_token()

    conn
    |> configure_session(renew: true)
    |> clear_session()
  end

  @doc """
  Logs the user out.

  It clears all session data for safety. See renew_session.
  """
  def log_out_user(conn) do
    token = get_session(conn, :access_token)
    token[:access_token] && Users.delete_user_access_token(token[:access_token])

    if live_socket_id = get_session(conn, :live_socket_id) do
      MixtapeWeb.Endpoint.broadcast(live_socket_id, "disconnect", %{})
    end

    conn
    |> renew_session()
    |> delete_resp_cookie(@remember_me_cookie)
    |> redirect(to: ~p"/")
  end

  @doc """
  Authenticates the user by looking into the session
  and remember me token.
  """
  def fetch_current_user(conn, _opts) do
    {token, conn} = ensure_access_token(conn)
    user = token[:access_token] && Users.get_user_by_access_token(token[:access_token])
    assign(conn, :current_user, user)
  end

  defp ensure_access_token(conn) do
    if token = get_session(conn, :access_token) do
      {token, conn}
    else
      {nil, conn}
    end
  end

  @doc """
  Handles mounting and authenticating the current_user in LiveViews.

  ## `on_mount` arguments

    * `:mount_current_user` - Assigns current_user
      to socket assigns based on user_token, or nil if
      there's no user_token or no matching user.

    * `:ensure_authenticated` - Authenticates the user from the session,
      and assigns the current_user to socket assigns based
      on user_token.
      Redirects to login page if there's no logged user.

    * `:redirect_if_user_is_authenticated` - Authenticates the user from the session.
      Redirects to signed_in_path if there's a logged user.

  ## Examples

  Use the `on_mount` lifecycle macro in LiveViews to mount or authenticate
  the current_user:

      defmodule MixtapeWeb.PageLive do
        use MixtapeWeb, :live_view

        on_mount {MixtapeWeb.UserAuth, :mount_current_user}
        ...
      end

  Or use the `live_session` of your router to invoke the on_mount callback:

      live_session :authenticated, on_mount: [{MixtapeWeb.UserAuth, :ensure_authenticated}] do
        live "/profile", ProfileLive, :index
      end
  """
  def on_mount(:mount_current_user, _params, session, socket) do
    {:cont, mount_current_user(socket, session)}
  end

  def on_mount(:ensure_authenticated, _params, session, socket) do
    socket = mount_current_user(socket, session)
    IO.puts("DESGRAÇA DO ON MOUNT")
    IO.inspect(socket.assigns)

    if socket.assigns.current_user do
      {:cont, socket}
    else
      socket =
        socket
        |> Phoenix.LiveView.put_flash(
          :error,
          "Você precisa estar logado para acessar esta página1."
        )
        |> Phoenix.LiveView.redirect(to: ~p"/")

      {:halt, socket}
    end
  end

  def on_mount(:redirect_if_user_is_authenticated, _params, session, socket) do
    socket = mount_current_user(socket, session)

    if socket.assigns.current_user do
      {:halt, Phoenix.LiveView.redirect(socket, to: signed_in_path(socket))}
    else
      {:cont, socket}
    end
  end

  defp mount_current_user(socket, session) do
    Phoenix.Component.assign_new(socket, :current_user, fn ->
      token = session["access_token"]

      if access_token = token[:access_token] do
        IO.puts("OQUE CHEGA AQUI" <> access_token)

        case Users.get_user_by_access_token(access_token) do
          nil ->
            nil

          user ->
            user
        end
      end
    end)
  end

  defp refresh_access_token(conn, refresh_token) do
    case SpotifyAPI.refresh_token(refresh_token) do
      {:ok, response} ->
        IO.puts("REFRESHED ENTROU AQUI")

        if response.status != 200 do
          IO.puts("REFRESHED ENTROU AQUI2")

          IO.inspect(response)
          conn
        else
          IO.inspect(response)
          expiration = DateTime.utc_now() |> DateTime.add(response.body["expires_in"], :second)

          response.body["access_token"]
          |> get_spotify_user()
          |> create_or_update_user(response.body["access_token"], response.body["refresh_token"])

          token = %{
            access_token: response.body["access_token"],
            timeout: expiration,
            refresh_token: response.body["refresh_token"]
          }

          IO.puts("OLHA ESSE REFRESHADO AQUI")
          IO.inspect(token)

          conn
          |> put_token_in_session(token)

          conn
        end

      {:error, response} ->
        IO.inspect(response)
        conn
    end
  end

  @doc """
  Used for routes that require the user to not be authenticated.
  """
  def redirect_if_user_is_authenticated(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
      |> redirect(to: signed_in_path(conn))
      |> halt()
    else
      conn
    end
  end

  @doc """
  Used for routes that require the user to be authenticated.

  If you want to enforce the user email is confirmed before
  they use the application at all, here would be a good place.
  """
  def require_authenticated_user(conn, _opts) do
    token = get_session(conn, :access_token)
    IO.inspect(token)

    if conn.assigns[:current_user] do
      if token = get_session(conn, :access_token) do
        if DateTime.compare(DateTime.utc_now(), token[:timeout]) == :gt && token[:refresh_token] do
          refresh_access_token(conn, token[:refresh_token])
        else
          conn
        end
      end
    else
      conn
      |> put_flash(:error, "Você precisa estar logado para acessar esta página2.")
      |> maybe_store_return_to()
      |> redirect(to: ~p"/")
      |> halt()
    end
  end

  defp put_token_in_session(conn, token) do
    IO.puts("O DA PORRA DO PUT TOKEN IN SESSIONS")
    IO.inspect(token)

    conn
    |> put_session(:access_token, token)
    |> put_session(:live_socket_id, "users_sessions:#{Base.url_encode64(token[:access_token])}")
  end

  defp maybe_store_return_to(%{method: "GET"} = conn) do
    put_session(conn, :user_return_to, current_path(conn))
  end

  defp maybe_store_return_to(conn), do: conn

  defp signed_in_path(_conn), do: ~p"/home"
end
