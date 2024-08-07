defmodule MixtapeWeb.Router do
  use MixtapeWeb, :router

  import MixtapeWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {MixtapeWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Other scopes may use custom stacks.
  # scope "/api", MixtapeWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:mixtape, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: MixtapeWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes
  scope "/", MixtapeWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{MixtapeWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/", LandingLive, :home
    end
  end

  scope "/", MixtapeWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      layout: {MixtapeWeb.Layouts, :mixtape},
      on_mount: [
        {MixtapeWeb.UserAuth, :ensure_authenticated},
        {MixtapeWeb.LiveHooks.Mixtapes, :fetch_user_mixtapes}
      ] do
      live "/home", CreateMixtapeLive, :home
      live "/wrapup/:id", UpdateMixtapeLive, :wrapup
    end
  end

  scope "/", MixtapeWeb do
    pipe_through [:browser]

    get "/webhook", SpotifyLoginController, :webhook
    get "/login", SpotifyLoginController, :login
    delete "/logout", UserController, :logout

    live_session :current_user,
      on_mount: [{MixtapeWeb.UserAuth, :mount_current_user}] do
    end
  end
end
