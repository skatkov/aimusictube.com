class Track < ApplicationRecord
  LABELS = { "generated" => "AI-generated", "assisted" => "AI-assisted" }.freeze

  belongs_to :artist

  validates :youtube_id, format: { with: /\A[A-Za-z0-9_-]{11}\z/ }
  validates :title, :genre, :duration, :evidence, presence: true
  validates :kind, inclusion: { in: LABELS.keys + %w[disclosed unverified] }
  validates :evidence_url, format: { with: /\Ahttps:\/\/[a-z0-9.-]+(?:[\/?#][^\s]*)?\z/i }

  def youtube_url
    "https://www.youtube.com/watch?v=#{youtube_id}"
  end

  def thumbnail_url
    "https://i.ytimg.com/vi/#{youtube_id}/hqdefault.jpg"
  end
end
