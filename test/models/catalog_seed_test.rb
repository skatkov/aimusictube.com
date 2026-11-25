require "test_helper"
require_relative "../../db/catalog_seed"

class CatalogSeedTest < ActiveSupport::TestCase
  test "a duplicate within an import names both entries and rolls back the whole import" do
    seed = CatalogSeed.new
    track = [ "a1234567890", "Original", "Pop", "3:12", "assisted", "Artist credit" ]
    seed.import { catalog_artist "First artist", "UC#{'a' * 22}", [ track ] }
    error = assert_raises(ArgumentError) do
      seed.import do
        catalog_artist "First artist", "UC#{'a' * 22}", [ track.dup.tap { |row| row[1] = "Changed" } ]
        catalog_artist "Second artist", "UC#{'b' * 22}", [ track ]
      end
    end
    [ track.first, "First artist", "Changed", "Second artist" ].each { |value| assert_includes error.message, value }
    assert_equal "Original", Track.sole.title
    assert_equal "First artist", Artist.sole.name
  end
end
