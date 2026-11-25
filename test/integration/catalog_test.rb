require "test_helper"

class CatalogTest < ActionDispatch::IntegrationTest
  setup do
    @artist = Artist.create!(name: "Test Artist", channel_id: "UC0000000000000000000000")
    @track = @artist.tracks.create!(title: "100% Signal", youtube_id: "AbCd1234_-z", duration: "3:14",
      genre: "Electronic", kind: "assisted", evidence: "Creator disclosure", evidence_url: "https://example.com/")
  end

  test "searches artist names and treats SQL wildcard characters as literal" do
    get root_path, params: { q: "test artist" }
    assert_response :success
    assert_select ".track h2", @track.title
    assert_select ".track .kind", "AI-assisted"

    get root_path, params: { q: "%" }
    assert_select ".track h2", @track.title

    get root_path, params: { q: "_" }
    assert_select ".track", count: 0

    get root_path, params: { q: "electronic", kind: "generated" }
    assert_select ".track", count: 0
  end

  test "shows artists and the source of a disclosure" do
    get artists_path
    assert_select "main a[href=?] strong", artist_path(@artist), @artist.name
    get artist_path(@artist)
    assert_select ".track h2", @track.title
    get track_path(@track)
    assert_select "a[href=?]", @track.evidence_url, "View disclosure source"
  end

  test "StarSinger artists with the same name and publisher keep distinct discographies" do
    one, two = %w[a b].map do |letter|
      artist = Artist.create!(name: "Shared name", channel_id: @artist.channel_id, starsinger_id: letter * 32)
      @track.dup.update!(artist: artist, youtube_id: letter * 11, title: "Song #{letter}")
      artist
    end

    get artists_path(source: "starsinger")
    assert_select "main .artist-row", count: 2
    assert_select "main .artist-row[href=?]", artist_path(@artist), count: 0
    [ one, two ].each do |artist|
      get artist_path(artist)
      assert_select ".track h2", count: 1, text: "Song #{artist.starsinger_id.first}"
      assert_select "a[href=?]", artist.starsinger_url, "StarSinger artist profile"
      assert_select "a[href=?]", @artist.youtube_url, "Publisher on YouTube"
    end
  end

  test "feed pages preserve search, filter, ranking and total across the page boundary" do
    TracksController::PAGE_SIZE.times do |n|
      @track.dup.update!(youtube_id: format("X%010d", n), play_count: n + 1)
    end
    filters = { q: @artist.name, kind: "assisted", genre: @track.genre, sort: "most_played" }
    get root_path(filters)
    assert_select ".track", count: TracksController::PAGE_SIZE
    assert_select ".result-count", /#{TracksController::PAGE_SIZE + 1} results/
    assert_select "nav a[rel=next][href=?]", root_path(filters.merge(page: 2))
    assert_select ".track-link[href=?]", track_path(@track), count: 0
    get root_path(filters.merge(page: 2))
    assert_select ".track", count: 1
    assert_select ".track-link[href=?]", track_path(@track)
    assert_select "nav a[rel=next]", count: 0
  end

  test "links to About from the masthead and shows live catalog counts" do
    get root_path
    assert_select "header a[href=?][aria-label=?]:not([aria-current])", about_path, "About AI Music Tube"
    assert_select "footer", /not affiliated with or endorsed by YouTube or Google/

    get about_path
    assert_response :success
    assert_select "header a[href=?][aria-current=page]", about_path
    assert_select "main h1", "About AI Music Tube"
    totals = css_select(".about-stats div").to_h { |row| [ row.at_css("dt").text, row.at_css("dd").text ] }
    assert_equal({ "YouTube uploads" => "1", "Artists and channels" => "1", "Catalog tags" => "3" }, totals)
    assert_select "main a[href=?]", root_path, "Browse the catalog"
    assert_select "main p", /isn’t affiliated with or endorsed by YouTube or Google/
    assert_select "footer", /Built by GPT-6\.2 Sol and @5katkov on X/
    assert_select "footer a[href=?]", "https://x.com/5katkov", "@5katkov on X"
  end

  test "home gives each artist a slot and the tag directory filters the feed" do
    @track.dup.tap { |t| t.update!(youtube_id: "BcDe2345_-z", title: "Another track") }
    second = Artist.create!(name: "Second Artist", channel_id: "UC1111111111111111111111")
    rock = @track.dup.tap { |t| t.update!(artist: second, youtube_id: "CdEf3456_-z", title: "Rock recording", genre: "Rock") }

    get root_path
    assert_equal [ @track.title, rock.title, "Another track" ], css_select(".track h2").map(&:text)
    assert_select "main a[href=?]", tags_path, "Browse tags"
    assert_select "main a[href=?]", root_path(genre: "Rock"), count: 0
    get tags_path
    assert_select ".tag-list a[href=?]", root_path(genre: "Electronic"), /Electronic\s+2/
    assert_select ".tag-list a[href=?]", root_path(genre: "Rock"), /Rock\s+1/
    get root_path, params: { genre: "Rock" }
    assert_select ".track h2", count: 1, text: rock.title
    assert_select ".result-count strong", "Rock"
  end

  test "old jazz mix bookmarks open the broader Mixes filter" do
    mix = @track.dup.tap { |t| t.update!(youtube_id: "CdEf3456_-z", genre: "Mixes", title: "Night mix") }
    get root_path, params: { genre: "Jazz mixes" }
    assert_select ".track h2", count: 1, text: mix.title
    assert_select ".result-count strong", "Mixes"
  end

  test "most played ranks site play clicks and is independent of private history" do
    favorite = @track.dup.tap { |t| t.update!(youtube_id: "BcDe2345_-z", title: "Zebra") }
    get track_path(@track)
    assert_equal 0, @track.reload.play_count
    post play_track_path(favorite), headers: { "Turbo-Frame" => "player_track_#{favorite.id}" }
    post play_track_path(favorite)
    assert_equal 1, Play.count
    assert_equal 2, favorite.reload.play_count
    delete history_path

    get tags_path, params: { sort: "most_played", q: "test artist" }
    filtered = root_path(sort: "most_played", q: "test artist", genre: @track.genre)
    assert_select ".tag-list a[href=?]", filtered
    get filtered
    assert_equal [ favorite.title, @track.title ], css_select(".track h2").map(&:text)
    assert_select ".track p", "2 site plays"
    assert_select ".filters [aria-current]", "Most played"
    assert_select ".search input[name=sort][value=most_played]"
  end

  test "artist suggestions open a GitHub pull request from Artists, About, and old bookmarks" do
    github = "https://github.com/skatkov/aimusictube.com/compare?expand=1"
    [ artists_path, about_path ].each do |path|
      get path
      assert_select "main a[href=?]", github, /pull request/i
    end
    get "/artist-submissions/new"
    assert_redirected_to github
    post "/artist-submissions"
    assert_response :not_found
  end

  test "tracks without an audio label keep their genre and evidence" do
    %w[disclosed unverified].each do |kind|
      @track.update!(kind: kind)
      get root_path
      assert_select ".track .video-meta", @track.genre
      assert_select ".track .kind", count: 0
      get track_path(@track)
      assert_select "#disclosure", "AI disclosure"
      assert_select ".description p", @track.evidence
      assert_select ".description a[href=?]", @track.evidence_url
      get tags_path
      assert_select ".tag-list a[href=?]", root_path(kind: kind), count: 0
    end
  end

  test "likes are private, idempotent and removable" do
    2.times { post track_like_path(@track) }
    assert_response :see_other
    get liked_path
    assert_select ".track", count: 1

    open_session do |other|
      other.get liked_path
      other.assert_select ".track", count: 0
    end

    delete track_like_path(@track)
    get liked_path
    assert_select ".track", count: 0
  end

  test "play loads an embedded player on demand and direct opens still redirect" do
    get track_path(@track)
    assert_select "iframe", count: 0
    assert_select "button.poster[aria-label=?] .play-badge", "Play #{@track.title}", text: "" do
      assert_select "svg[aria-hidden=true] use[href='/icons.svg#play']"
    end
    assert_select "button", "Watch on YouTube"
    assert_no_difference "Play.count" do
      get track_path(@track)
      get history_path
    end
    player = "player_track_#{@track.id}"
    assert_difference "Play.count", 1 do
      post play_track_path(@track), headers: { "Turbo-Frame" => player }
    end
    assert_response :success
    assert_select "turbo-frame[id=?] iframe[src=?]", player, "https://www.youtube-nocookie.com/embed/#{@track.youtube_id}?autoplay=1&playsinline=1&rel=0"
    previous_open = 1.day.ago
    Play.sole.update!(opened_at: previous_open)
    assert_no_difference "Play.count" do
      post play_track_path(@track), params: { url: "https://example.com/" }
    end
    assert_redirected_to @track.youtube_url
    assert_operator Play.sole.opened_at, :>, previous_open
    get history_path
    assert_select ".track h2", @track.title
    assert_equal 1, Play.count

    open_session do |other|
      other.get history_path
      other.assert_select ".track", count: 0
      other.delete history_path
    end
    assert_equal 1, Play.count

    delete history_path
    get history_path
    assert_select ".track", count: 0
  end

  test "creating a playlist does not write its name to request or SQL logs" do
    output = StringIO.new
    sink = ActiveSupport::Logger.new(output)
    Rails.logger.broadcast_to(sink)
    name = "Private name #{SecureRandom.hex(8)}"
    post playlists_path, params: { playlist: { name: name } }
    assert_response :redirect
    assert_includes output.string, "Parameters:"
    assert_includes output.string, "INSERT INTO"
    assert_not_includes output.string, name
  ensure
    Rails.logger.stop_broadcasting_to(sink)
  end

  test "creates playlists, adds a track once, and prevents access from a different browser" do
    post playlists_path, params: { playlist: { name: " " } }
    assert_response :unprocessable_content
    assert_select "[role=alert]", "Name can't be blank"

    post playlists_path, params: { playlist: { name: " Night drive " } }
    playlist = Playlist.find_by!(name: "Night drive")
    assert_redirected_to playlist
    get track_path(@track)
    assert_select "select[name=playlist_id] option", "Night drive"
    2.times do
      post track_playlist_entries_path(@track), params: { playlist_id: playlist.id }
      assert_redirected_to @track
    end
    entry = playlist.playlist_entries.sole
    get playlist_path(playlist)
    assert_select ".track h2", @track.title

    open_session do |other|
      other.get playlist_path(playlist)
      other.assert_response :not_found
      other.post track_playlist_entries_path(@track), params: { playlist_id: playlist.id }
      other.assert_response :not_found
      other.delete playlist_entry_path(playlist, entry)
      other.assert_response :not_found
      other.delete playlist_path(playlist)
      other.assert_response :not_found
    end

    delete playlist_entry_path(playlist, entry)
    assert_redirected_to playlist
    assert_empty playlist.playlist_entries.reload

    post track_playlist_entries_path(@track), params: { playlist_id: playlist.id }
    assert_difference "PlaylistEntry.count", -1 do
      delete playlist_path(playlist)
    end
    assert_redirected_to playlists_path
  end

  test "creating a first playlist from a track saves that track and preserves context on validation errors" do
    get track_path(@track)
    assert_select "a[href=?]", playlists_path(track_id: @track.id), "Create a playlist for this track"
    get playlists_path(track_id: @track.id)
    assert_select "input[name=track_id][value=?]", @track.id.to_s

    post playlists_path, params: { track_id: @track.id, playlist: { name: " " } }
    assert_response :unprocessable_content
    assert_select "input[name=track_id][value=?]", @track.id.to_s

    post playlists_path, params: { track_id: @track.id, playlist: { name: "First playlist" } }
    playlist = Playlist.find_by!(name: "First playlist")
    assert_redirected_to playlist
    assert_equal @track, playlist.playlist_entries.sole.track
  end
end
