class CatalogSeed
  def import(&block)
    @uploads = {}
    ActiveRecord::Base.transaction(requires_new: true) { instance_exec(&block) }
  end

  private

  def catalog_artist(name, channel_id, tracks, avatar: nil, starsinger_id: nil)
    key = starsinger_id ? { starsinger_id: starsinger_id } : { channel_id: channel_id, starsinger_id: nil }
    artist = Artist.find_or_initialize_by(key)
    artist.update!(name: name, channel_id: channel_id, avatar_url: ("https://yt3.googleusercontent.com/#{avatar}=s96-c-k-c0x00ffffff-no-rj" if avatar))

    tracks.each do |youtube_id, title, genre, duration, kind, evidence, source|
      entry = "#{name} (#{starsinger_id || channel_id}): #{title}"
      raise ArgumentError, "Duplicate YouTube ID #{youtube_id}: #{@uploads[youtube_id]} and #{entry}" if @uploads.key?(youtube_id)
      @uploads[youtube_id] = entry

      track = Track.find_or_initialize_by(youtube_id: youtube_id)
      track.update!(artist: artist, title: title, genre: genre, duration: duration, kind: kind,
        evidence: evidence, evidence_url: source || "https://www.youtube.com/watch?v=#{youtube_id}")
    end
  end
end
