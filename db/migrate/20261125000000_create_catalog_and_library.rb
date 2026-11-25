class CreateCatalogAndLibrary < ActiveRecord::Migration[8.1]
  def change
    create_table :artists do |t|
      t.string :name, null: false
      t.string :channel_id, null: false, index: { unique: true }
    end

    create_table :tracks do |t|
      t.references :artist, null: false, foreign_key: true
      t.string :youtube_id, null: false, index: { unique: true }
      t.string :title, null: false
      t.string :genre, null: false
      t.string :duration, null: false
      t.string :kind, null: false
      t.text :evidence, null: false
      t.string :evidence_url, null: false
    end

    create_table :likes do |t|
      t.references :track, null: false, foreign_key: true
      t.string :browser_key, null: false
      t.timestamps
      t.index %i[browser_key track_id], unique: true
    end

    create_table :plays do |t|
      t.references :track, null: false, foreign_key: true
      t.string :browser_key, null: false
      t.datetime :opened_at, null: false
      t.index %i[browser_key track_id], unique: true
    end

    create_table :playlists do |t|
      t.string :browser_key, null: false, index: true
      t.string :name, null: false
      t.timestamps
    end

    create_table :playlist_entries do |t|
      t.references :playlist, null: false, foreign_key: true, index: false
      t.references :track, null: false, foreign_key: true
      t.index %i[playlist_id track_id], unique: true
    end
  end
end
