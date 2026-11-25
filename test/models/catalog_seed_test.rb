require "test_helper"
require_relative "../../db/catalog_seed"

class CatalogSeedTest < ActiveSupport::TestCase
  setup do
    @seed = CatalogSeed.new
    @track = { "youtube_id" => "a1234567890", "title" => "Original", "duration" => "3:12" }
    @artist = { "name" => "First artist", "channel_id" => "UC#{'a' * 22}", "genre" => "Pop",
      "credit" => { "kind" => "assisted", "evidence" => "Artist credit", "evidence_url" => "https://example.com/credits" },
      "tracks" => [ @track ] }
  end

  test "a duplicate within an import names both entries and rolls back the whole import" do
    @seed.import([ @artist ])
    second = @artist.merge("name" => "Second artist", "starsinger_id" => "b" * 32)
    Track.transaction(requires_new: true) do
      error = assert_raises(ArgumentError) do
        @seed.import([@artist.merge("tracks" => [@track.merge("title" => "Changed")]), second])
      end
      assert_eql "Duplicate YouTube ID #{@track.fetch("youtube_id")}: First artist (#{@artist.fetch("channel_id")}): Changed and Second artist (#{second.fetch("starsinger_id")}): Original",
        error.message
      assert_equal "Original", Track.sole.title
      assert_equal "First artist", Artist.sole.name
    end
  end

  test "a track credit replaces the whole shared credit, including its source" do
    exception = @track.merge("youtube_id" => "b1234567890", "title" => "Different credit", "genre" => "Rock",
      "credit" => { "kind" => "unverified", "evidence" => "No audio credit on this upload" })
    @seed.import([ @artist.merge("tracks" => [ @track, exception ]) ])

    shared, unique = Track.order(:id)
    assert_equal [ "Pop", "assisted", "Artist credit", "https://example.com/credits" ], [ shared.genre, shared.kind, shared.evidence, shared.evidence_url ]
    assert_equal [ "Rock", "unverified", "No audio credit on this upload", unique.youtube_url ], [ unique.genre, unique.kind, unique.evidence, unique.evidence_url ]
  end

  test "misspelled profile, track and source keys cannot silently inherit other values" do
    credit = { "kind" => "generated", "evidence" => "Upload credit", "evidence_uri" => "https://example.com/song" }
    [ @artist.merge("starsingerID" => "b" * 32),
      @artist.merge("tracks" => [ @track.merge("credits" => credit) ]),
      @artist.merge("tracks" => [ @track.merge("credit" => credit) ]) ].each do |bad|
      assert_raises(ArgumentError) { @seed.import([ bad ]) }
    end
    assert_empty Artist.all
    assert_empty Track.all
  end

  test "catalog schema rejects invalid types and durations before importing" do
    [{"title" => 123}, {"duration" => "3:99"}, {"duration" => "1:99:59"}, {"duration" => "3:19\nextra"}].each do |invalid|
      record = @artist.merge("tracks" => [@track.merge(invalid)])

      error = assert_raises(ArgumentError) { @seed.import([record]) }
      assert_includes error.message, "/0/tracks/0/#{invalid.keys.first}"
    end
    assert_empty Artist.all
  end

  test "reports the schema error without dumping the invalid entry or the schema" do
    error = assert_raises(ArgumentError) { @seed.import([]) }
    assert_eql "db/catalog.json: array size at root is less than: 1", error.message
  end

  test "long mixes can use either minutes alone or hours and minutes" do
    first = @track.merge("duration" => "99:59")
    second = @track.merge("youtube_id" => "b1234567890", "duration" => "1:39:59")
    @seed.import([@artist.merge("tracks" => [first, second])])
    assert_eql ["99:59", "1:39:59"], Track.order(:id).pluck(:duration)
  end

  test "a track needs its own genre and credit when no artist defaults are supplied" do
    %w[genre credit].each do |field|
      error = assert_raises(ArgumentError) { @seed.import([@artist.except(field)]) }
      assert_includes error.message, "/0/tracks/0"
      assert_includes error.message, field
    end

    track = @track.merge("genre" => "Pop", "credit" => @artist.fetch("credit"))
    @seed.import([@artist.except("genre", "credit").merge("tracks" => [track])])
    assert_eql "Pop", Track.sole.genre
  end

  test "a second block of uploads cannot overwrite the same artist's identity" do
    later = @artist.merge("name" => "Wrong artist", "tracks" => [ @track.merge("youtube_id" => "b1234567890") ])
    error = assert_raises(ArgumentError) { @seed.import([ @artist, later ]) }
    assert_includes error.message, @artist.fetch("channel_id")
    assert_empty Track.all
  end

  test "an artist can use different defaults in separate blocks" do
    second = @track.merge("title" => "Second", "youtube_id" => "b1234567890")
    block = @artist.merge("genre" => "Rock", "credit" => {"kind" => "generated", "evidence" => "Second credit"}, "tracks" => [second])

    @seed.import([@artist, block])
    assert_eql [["Pop", "assisted"], ["Rock", "generated"]], Artist.sole.tracks.order(:id).pluck(:genre, :kind)
  end

  test "artist profiles keep their identity when they share or change publisher channels" do
    avatar = "ytc/abc"
    profile = @artist.merge("starsinger_id" => "b" * 32, "avatar" => avatar)
    other_profile = profile.merge("starsinger_id" => "c" * 32, "tracks" => [@track.merge("youtube_id" => "b1234567890")])
    channel = @artist.merge("tracks" => [@track.merge("youtube_id" => "c1234567890")])
    @seed.import([profile, other_profile, channel])

    artist = Track.find_by!(youtube_id: @track.fetch("youtube_id")).artist
    assert_eql profile.fetch("starsinger_id"), artist.starsinger_id
    assert_eql "https://yt3.googleusercontent.com/#{avatar}=s96-c-k-c0x00ffffff-no-rj", artist.avatar_url
    assert_nil Track.find_by!(youtube_id: "c1234567890").artist.avatar_url
    assert_eql [profile.fetch("starsinger_id"), other_profile.fetch("starsinger_id"), nil], Track.order(:id).map { |track| track.artist.starsinger_id }

    new_channel = "UC#{'d' * 22}"
    @seed.import([profile.except("avatar").merge("channel_id" => new_channel)])
    assert_eql new_channel, artist.reload.channel_id
    assert_nil artist.avatar_url
    assert_eql artist.id, Track.find_by!(youtube_id: @track.fetch("youtube_id")).artist_id
    assert_eql 3, Artist.count
  end

  test "conflicting profile blocks identify the profile rather than its publisher" do
    profile = @artist.merge("starsinger_id" => "b" * 32)
    later = profile.merge("name" => "Wrong artist", "tracks" => [@track.merge("youtube_id" => "b1234567890")])
    error = assert_raises(ArgumentError) { @seed.import([profile, later]) }
    assert_eql "Conflicting artist details for #{profile.fetch("starsinger_id")}", error.message
  end

  test "ordinary artists are matched by channel, not by their missing profile ID" do
    channel = "UC#{'b' * 22}"
    second = @artist.merge("name" => "Second artist", "channel_id" => channel,
      "tracks" => [@track.merge("youtube_id" => "b1234567890")])
    @seed.import([@artist, second])

    assert_eql [@artist.fetch("channel_id"), channel], Track.order(:id).map { |track| track.artist.channel_id }
  end
end
