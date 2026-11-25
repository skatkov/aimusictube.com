class AddPlayCountToTracks < ActiveRecord::Migration[8.1]
  def change
    add_column :tracks, :play_count, :integer, null: false, default: 0
    reversible do |dir|
      dir.up { execute "UPDATE tracks SET play_count = (SELECT COUNT(*) FROM plays WHERE plays.track_id = tracks.id)" }
    end
  end
end
