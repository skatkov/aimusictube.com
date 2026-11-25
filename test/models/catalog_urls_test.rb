require "test_helper"

class CatalogUrlsTest < ActiveSupport::TestCase
  test "a YouTube channel and upload link to their original media" do
    channel_id = "UC0000000000000000000000"
    upload_id = "AbCd1234_-z"

    assert_eql "https://www.youtube.com/channel/#{channel_id}", Artist.new(channel_id:).youtube_url
    assert_eql "https://www.youtube.com/watch?v=#{upload_id}", Track.new(youtube_id: upload_id).youtube_url
    assert_eql "https://i.ytimg.com/vi/#{upload_id}/hqdefault.jpg", Track.new(youtube_id: upload_id).thumbnail_url
  end

  test "only artists with a StarSinger profile have a StarSinger link" do
    starsinger_id = "a" * 32

    assert_nil Artist.new.starsinger_url
    assert_eql "https://starsinger.ai/artist/#{starsinger_id}", Artist.new(starsinger_id:).starsinger_url
  end
end
