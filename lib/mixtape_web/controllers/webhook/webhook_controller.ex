defmodule MixtapeWeb.WebhookController do
  use MixtapeWeb, :controller

  def webhook(conn, params) do
    code = params["code"]
    state = params["state"]

    conn
    |> put_session(:code, code)
    |> put_session(:state, state)
    |> redirect(to: "/")
  end
end
