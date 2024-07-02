defmodule Mixtape.Mixtapes do
  import Ecto.Query, warn: false
  alias Mixtape.Repo

  alias Mixtape.Mixtapes.{Mixtape}

  def register_mixtape(attrs) do
    %Mixtape{}
    |> Mixtape.changeset(attrs)
    |> Repo.insert()
  end

  def get_mixtapes_by_user_id(user_id) when is_binary(user_id) do
    Repo.get_by(Mixtape, user_id: user_id)
  end
end
