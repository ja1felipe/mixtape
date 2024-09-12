defmodule Mixtape.Repo.Migrations.AddSpotifyPlaylistIdOnMixtapeTable do
  use Ecto.Migration

  def change do
    alter table(:mixtapes) do
      add :spotify_playlist_id, :string
    end
  end
end
