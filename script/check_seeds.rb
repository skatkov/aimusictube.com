abort "Run bin/ci with an empty test database" unless Rails.env.test? && Track.none? && Artist.none?

Rails.application.load_seed
artists = Artist.order(:id).pluck(:id, :channel_id, :starsinger_id)
tracks = Track.order(:id).pluck(:id, :youtube_id, :artist_id)
track = Track.first!
playlist = Playlist.create!(browser_key: "seed-check", name: "Keep this playlist")
entry = playlist.playlist_entries.create!(track: track)
like = Like.create!(browser_key: playlist.browser_key, track: track)
play = Play.create!(browser_key: playlist.browser_key, track: track, opened_at: Time.current)
track.increment!(:play_count)

Rails.application.load_seed
raise "Artist IDs changed" unless Artist.order(:id).pluck(:id, :channel_id, :starsinger_id) == artists
raise "Track IDs or owners changed" unless Track.order(:id).pluck(:id, :youtube_id, :artist_id) == tracks
raise "Playlist entry changed" unless entry.reload.playlist == playlist && entry.track_id == track.id
raise "Like or history changed" unless [ like, play ].all? { |row| row.reload.track_id == track.id && row.browser_key == playlist.browser_key }
raise "Play count changed" unless track.reload.play_count == 1
