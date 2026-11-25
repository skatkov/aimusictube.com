class IdentifyArtistsOnSharedChannels < ActiveRecord::Migration[8.1]
  def change
    add_column :artists, :starsinger_id, :string
    remove_index :artists, :channel_id, unique: true
    add_index :artists, :channel_id, unique: true, where: "starsinger_id IS NULL"
    add_index :artists, :starsinger_id, unique: true
  end
end
