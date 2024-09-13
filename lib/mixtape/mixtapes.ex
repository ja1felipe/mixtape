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
    Repo.all(from(m in Mixtape, where: m.user_id == ^user_id))
  end

  def get_by_id(id) when is_binary(id) do
    Repo.get!(Mixtape, id)
  end

  def update_mixtape(id, attrs) do
    mixtape = get_by_id(id)

    mixtape
    |> Mixtape.changeset(attrs)
    |> Repo.update()
  end
end
