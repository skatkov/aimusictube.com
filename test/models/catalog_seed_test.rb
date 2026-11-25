require "test_helper"
require_relative "../../db/catalog_seed"

class CatalogSeedTest < ActiveSupport::TestCase
  test "a duplicate within an import names both entries and rolls back the whole import" do
    seed = CatalogSeed.new
    track = { "youtube_id" => "a1234567890", "title" => "Original", "duration" => "3:12" }
    first = { "name" => "First artist", "channel_id" => "UC#{'a' * 22}", "genre" => "Pop",
      "credit" => { "kind" => "assisted", "evidence" => "Artist credit" }, "tracks" => [ track ] }
    seed.import([ first ])
    error = assert_raises(ArgumentError) do
      seed.import([ first.merge("tracks" => [ track.merge("title" => "Changed") ]),
        first.merge("name" => "Second artist", "channel_id" => "UC#{'b' * 22}") ])
    end
    [ track.fetch("youtube_id"), "First artist", "Changed", "Second artist" ].each { |value| assert_includes error.message, value }
    assert_equal "Original", Track.sole.title
    assert_equal "First artist", Artist.sole.name
  end

  test "a track credit replaces the whole shared credit, including its source" do
    common = { "youtube_id" => "a1234567890", "title" => "Shared credit", "duration" => "3:12" }
    exception = common.merge("youtube_id" => "b1234567890", "title" => "Different credit", "genre" => "Rock",
      "credit" => { "kind" => "unverified", "evidence" => "No audio credit on this upload" })
    CatalogSeed.new.import([ { "name" => "Artist", "channel_id" => "UC#{'a' * 22}", "genre" => "Pop",
      "credit" => { "kind" => "assisted", "evidence" => "Artist credit", "evidence_url" => "https://example.com/credits" },
      "tracks" => [ common, exception ] } ])

    shared, unique = Track.order(:id)
    assert_equal [ "Pop", "assisted", "Artist credit", "https://example.com/credits" ], [ shared.genre, shared.kind, shared.evidence, shared.evidence_url ]
    assert_equal [ "Rock", "unverified", "No audio credit on this upload", unique.youtube_url ], [ unique.genre, unique.kind, unique.evidence, unique.evidence_url ]
  end
end
