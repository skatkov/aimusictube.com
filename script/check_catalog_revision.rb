require "json"
require "open3"

# Compares upload identities without importing either catalog into a database.
module CatalogRevision
  def self.owners(entries)
    entries.map { |artist| upload_owners(artist) }.reduce({}, :merge!)
  end

  def self.upload_owners(artist)
    owner = artist["starsinger_id"] || artist.fetch("channel_id")
    artist.fetch("tracks").to_h { |track| [track.fetch("youtube_id"), owner] }
  end

  def self.changed_uploads(previous, current)
    current_owners = owners(current)
    owners(previous).reject { |id, owner| current_owners[id] == owner }.keys.sort
  end
end

if $PROGRAM_NAME == __FILE__
  base = ENV.fetch("CATALOG_BASE")
  previous, status = Open3.capture2("git", "show", "#{base}:db/catalog.json")
  abort "Could not read db/catalog.json at #{base}" unless status.success?

  current = File.read("db/catalog.json")
  changes = CatalogRevision.changed_uploads(JSON.parse(previous), JSON.parse(current))
  unless changes.empty?
    abort "Catalog uploads removed or moved to a different artist: #{changes.join(", ")}. Submit these corrections separately with an explicit data migration."
  end
end
