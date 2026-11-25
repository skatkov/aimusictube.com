# A track saved into a playlist.
class PlaylistEntry < ApplicationRecord
  belongs_to :playlist
  belongs_to :track
end
