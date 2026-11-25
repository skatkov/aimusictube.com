class CatalogSeed
  def import(entries)
    @uploads = {}
    ActiveRecord::Base.transaction(requires_new: true) { entries.each { |entry| catalog_artist(entry) } }
  end

  private

  def catalog_artist(entry)
    name, channel_id = entry.fetch_values("name", "channel_id")
    starsinger_id, avatar = entry.values_at("starsinger_id", "avatar")
    key = starsinger_id ? { starsinger_id: starsinger_id } : { channel_id: channel_id, starsinger_id: nil }
    artist = Artist.find_or_initialize_by(key)
    artist.update!(name: name, channel_id: channel_id, avatar_url: ("https://yt3.googleusercontent.com/#{avatar}=s96-c-k-c0x00ffffff-no-rj" if avatar))

    entry.fetch("tracks").each do |row|
      youtube_id, title, duration = row.fetch_values("youtube_id", "title", "duration")
      owner = "#{name} (#{starsinger_id || channel_id}): #{title}"
      raise ArgumentError, "Duplicate YouTube ID #{youtube_id}: #{@uploads[youtube_id]} and #{owner}" if @uploads.key?(youtube_id)
      @uploads[youtube_id] = owner

      track = Track.find_or_initialize_by(youtube_id: youtube_id)
      genre = row.fetch("genre") { entry.fetch("genre") }
      credit = row.fetch("credit") { entry.fetch("credit") }
      track.update!(artist: artist, title: title, duration: duration, genre: genre, kind: credit.fetch("kind"),
        evidence: credit.fetch("evidence"), evidence_url: credit.fetch("evidence_url") { track.youtube_url })
    end
  end
end
