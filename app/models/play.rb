# The last time a browser requested playback of a track.
class Play < ApplicationRecord
  belongs_to :track
end
