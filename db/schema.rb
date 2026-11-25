# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_11_25_000005) do
  create_table "artist_submissions", force: :cascade do |t|
    t.string "youtube_url", null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "artists", force: :cascade do |t|
    t.string "name", null: false
    t.string "channel_id", null: false
    t.string "avatar_url"
    t.string "starsinger_id"
    t.string "search_name", default: "", null: false
    t.index ["channel_id"], name: "index_artists_on_channel_id", unique: true, where: "starsinger_id IS NULL"
    t.index ["starsinger_id"], name: "index_artists_on_starsinger_id", unique: true
  end

  create_table "likes", force: :cascade do |t|
    t.integer "track_id", null: false
    t.string "browser_key", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["browser_key", "track_id"], name: "index_likes_on_browser_key_and_track_id", unique: true
    t.index ["track_id"], name: "index_likes_on_track_id"
  end

  create_table "playlist_entries", force: :cascade do |t|
    t.integer "playlist_id", null: false
    t.integer "track_id", null: false
    t.index ["playlist_id", "track_id"], name: "index_playlist_entries_on_playlist_id_and_track_id", unique: true
    t.index ["track_id"], name: "index_playlist_entries_on_track_id"
  end

  create_table "playlists", force: :cascade do |t|
    t.string "browser_key", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["browser_key"], name: "index_playlists_on_browser_key"
  end

  create_table "plays", force: :cascade do |t|
    t.integer "track_id", null: false
    t.string "browser_key", null: false
    t.datetime "opened_at", null: false
    t.index ["browser_key", "track_id"], name: "index_plays_on_browser_key_and_track_id", unique: true
    t.index ["track_id"], name: "index_plays_on_track_id"
  end

  create_table "tracks", force: :cascade do |t|
    t.integer "artist_id", null: false
    t.string "youtube_id", null: false
    t.string "title", null: false
    t.string "genre", null: false
    t.string "duration", null: false
    t.string "kind", null: false
    t.text "evidence", null: false
    t.string "evidence_url", null: false
    t.integer "play_count", default: 0, null: false
    t.text "search_text", default: "", null: false
    t.index ["artist_id"], name: "index_tracks_on_artist_id"
    t.index ["youtube_id"], name: "index_tracks_on_youtube_id", unique: true
  end

  add_foreign_key "likes", "tracks"
  add_foreign_key "playlist_entries", "playlists"
  add_foreign_key "playlist_entries", "tracks"
  add_foreign_key "plays", "tracks"
  add_foreign_key "tracks", "artists"
end
