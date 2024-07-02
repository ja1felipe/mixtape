defmodule Mixtape.Repo.Migrations.CreateMixtapes do
  use Ecto.Migration

  def change do
    create table(:mixtapes, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :tracks, {:array, :map}
      add :artists, {:array, :map}
      add :status, :string

      add :user_id,
          references(:users,
            type: :binary_id,
            primary_key: true,
            on_delete: :delete_all,
            on_update: :update_all
          ),
          null: false

      timestamps(type: :utc_datetime)
    end
  end
end
