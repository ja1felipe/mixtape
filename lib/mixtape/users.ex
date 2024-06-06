defmodule Mixtape.Users do
  @moduledoc """
  The Users context.
  """

  import Ecto.Query, warn: false
  alias Mixtape.Repo

  alias Mixtape.Users.{User}

  ## Database getters

  @doc """
  Gets a user by email.

  ## Examples

      iex> get_user_by_email("foo@example.com")
      %User{}

      iex> get_user_by_email("unknown@example.com")
      nil

  """
  def get_user_by_email(email) when is_binary(email) do
    Repo.get_by(User, email: email)
  end

  def get_user_by_spotify_id(spotify_id) when is_binary(spotify_id) do
    Repo.get_by(User, spotify_id: spotify_id)
  end

  def get_user_by_access_token(access_token) when is_binary(access_token) do
    Repo.get_by(User, access_token: access_token)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  ## User registration

  @doc """
  Registers a user.

  ## Examples

      iex> register_user(%{field: value})
      {:ok, %User{}}

      iex> register_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def register_user(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user_registration(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_registration(%User{} = user, attrs \\ %{}) do
    User.registration_changeset(user, attrs, hash_password: false, validate_email: false)
  end

  def delete_user_access_token(token) do
    user = Repo.get_by(User, access_token: token)

    if user do
      changeset = User.registration_changeset(user, %{access_token: nil})

      case Repo.update(changeset) do
        {:ok, updated_user} ->
          {:ok, updated_user}

        {:error, changeset} ->
          {:error, changeset.errors}
      end
    else
      {:error, :not_found}
    end
  end

  def update_user_access_token(user, token, refresh_token) do
    changeset =
      User.registration_changeset(user, %{access_token: token, refresh_token: refresh_token})

    case Repo.update(changeset) do
      {:ok, updated_user} ->
        {:ok, updated_user}

      {:error, changeset} ->
        {:error, changeset.errors}
    end
  end
end
