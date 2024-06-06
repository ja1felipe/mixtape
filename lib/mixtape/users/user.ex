defmodule Mixtape.Users.User do
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :email, :string
    field :access_token, :string, redact: true
    field :refresh_token, :string, redact: true
    field :spotify_id, :string
    field :name, :string

    timestamps(type: :utc_datetime)
  end

  def registration_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:email, :access_token, :refresh_token, :spotify_id, :name])
    |> validate_spotify_id(opts)
  end

  defp validate_spotify_id(changeset, opts) do
    changeset
    |> validate_required([:spotify_id])
    |> maybe_validate_unique_spotify_id(opts)
  end

  defp maybe_validate_unique_spotify_id(changeset, opts) do
    if Keyword.get(opts, :validate_spotify_id, true) do
      changeset
      |> unsafe_validate_unique(:spotify_id, Mixtape.Repo)
      |> unique_constraint(:spotify_id)
    else
      changeset
    end
  end
end
