defmodule Mixtape.Mixtapes.Mixtape do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "mixtapes" do
    field :name, :string
    field :tracks, {:array, :map}
    field :artists, {:array, :map}
    field :status, Ecto.Enum, values: [:published, :unpublished], default: :unpublished
    belongs_to :user, Mixtape.Users.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(mixtape, attrs) do
    mixtape
    |> cast(attrs, [:name, :tracks, :arists, :status, :user_id])
    |> validate_required([:user_id, :tracks, :artists])
  end
end
