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
    error = assert_raises(ArgumentError) do
      @seed.import([ @artist.merge("tracks" => [ @track.merge("title" => "Changed") ]),
        @artist.merge("name" => "Second artist", "channel_id" => "UC#{'b' * 22}") ])
    end
    [ @track.fetch("youtube_id"), "First artist", "Changed", "Second artist" ].each { |value| assert_includes error.message, value }
    assert_equal "Original", Track.sole.title
    assert_equal "First artist", Artist.sole.name
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
    [{"title" => 123}, {"duration" => "3:99"}, {"duration" => "3:19\nextra"}].each do |invalid|
      record = @artist.merge("tracks" => [@track.merge(invalid)])

      error = assert_raises(ArgumentError) { @seed.import([record]) }
      assert_includes error.message, "/0/tracks/0/#{invalid.keys.first}"
    end
    assert_empty Artist.all
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
end
