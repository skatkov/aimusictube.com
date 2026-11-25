class Artist < ApplicationRecord
  has_many :tracks

  validates :name, presence: true
  validates :channel_id, format: { with: /\AUC[A-Za-z0-9_-]{22}\z/ }
  validates :starsinger_id, format: { with: /\A[a-z0-9]{32}\z/ }, allow_nil: true

  def youtube_url
    "https://www.youtube.com/channel/#{channel_id}"
  end

  def starsinger_url
    "https://starsinger.ai/artist/#{starsinger_id}" if starsinger_id
  end
end
