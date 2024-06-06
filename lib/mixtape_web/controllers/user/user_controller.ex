defmodule MixtapeWeb.UserController do
  use MixtapeWeb, :controller
  alias MixtapeWeb.UserAuth

  def logout(conn, _params) do
    conn
    |> put_flash(:info, "Deslogado com sucesso, até mais!")
    |> UserAuth.log_out_user()
  end
end
