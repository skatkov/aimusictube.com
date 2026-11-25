require "test_helper"
require_relative "../../script/check_catalog_revision"

class CatalogRevisionTest < ActiveSupport::TestCase
  test "new uploads are allowed, but replacing an ID or moving a track is reported" do
    first = {"youtube_id" => "aaaaaaaaaaa"}
    second = {"youtube_id" => "bbbbbbbbbbb"}
    new_upload = {"youtube_id" => "ccccccccccc"}
    artist = {"channel_id" => "first channel", "tracks" => [first, second]}
    other = {"channel_id" => "second channel", "tracks" => [new_upload]}

    assert_empty CatalogRevision.changed_uploads([artist], [artist, other])
    assert_eql %w[aaaaaaaaaaa bbbbbbbbbbb], CatalogRevision.changed_uploads([artist], [other.merge("tracks" => [first, new_upload])])
  end

  test "a StarSinger profile owns uploads independently of its publisher channel" do
    track = {"youtube_id" => "aaaaaaaaaaa"}
    artist = {"starsinger_id" => "first profile", "channel_id" => "publisher", "tracks" => [track]}

    assert_empty CatalogRevision.changed_uploads([artist], [artist.merge("channel_id" => "new publisher")])
    assert_eql ["aaaaaaaaaaa"], CatalogRevision.changed_uploads([artist], [artist.merge("starsinger_id" => "other profile")])
  end
end
