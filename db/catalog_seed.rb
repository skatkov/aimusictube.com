require "json_schemer"

# Validates and imports catalog records without replacing their IDs.
class CatalogSeed
  SCHEMA = JSONSchemer.schema(File.read(File.join(__dir__, "catalog.schema.json")), regexp_resolver: "ecma")

  def import(entries)
    if (error = SCHEMA.validate(entries).first)
      raise ArgumentError, "db/catalog.json: #{error.fetch("error")}"
    end

    profiles = {}
    uploads = {}
    ActiveRecord::Base.transaction(requires_new: true) do
      entries.each do |entry|
        rows = entry.fetch("tracks")
        defaults = entry.slice("genre", "credit")
        artist = catalog_artist(entry.except("genre", "credit", "tracks"), profiles)
        rows.each { |row| catalog_track(artist, defaults.merge(row), uploads) }
      end
    end
  end

  private

  def catalog_artist(header, profiles)
    name, channel_id = header.fetch_values("name", "channel_id")
    starsinger_id, avatar = header.values_at("starsinger_id", "avatar")
    key = starsinger_id ? { starsinger_id: starsinger_id } : { channel_id: channel_id, starsinger_id: nil }
    first_header = profiles[key] ||= header
    raise ArgumentError, "Conflicting artist details for #{starsinger_id || channel_id}" unless first_header == header
    artist = Artist.find_or_initialize_by(key)
    artist.update!(name: name, channel_id: channel_id, avatar_url: ("https://yt3.googleusercontent.com/#{avatar}=s96-c-k-c0x00ffffff-no-rj" if avatar))
    artist
  end

  def catalog_track(artist, row, uploads)
    youtube_id, title, duration, genre, credit = row.fetch_values("youtube_id", "title", "duration", "genre", "credit")
    owner = "#{artist.name} (#{artist.starsinger_id || artist.channel_id}): #{title}"
    raise ArgumentError, "Duplicate YouTube ID #{youtube_id}: #{uploads[youtube_id]} and #{owner}" if uploads.key?(youtube_id)
    uploads[youtube_id] = owner

    track = Track.find_or_initialize_by(youtube_id: youtube_id)
    track.update!(artist: artist, title: title, duration: duration, genre: genre, kind: credit.fetch("kind"),
      evidence: credit.fetch("evidence"), evidence_url: credit.fetch("evidence_url") { track.youtube_url })
  end
end
