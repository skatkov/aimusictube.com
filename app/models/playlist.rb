class Playlist < ApplicationRecord
  has_many :playlist_entries, dependent: :delete_all

  normalizes :name, with: ->(name) { name.strip }
  validates :name, presence: true, length: { maximum: 80 }
end
