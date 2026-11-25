class AddAvatarUrlToArtists < ActiveRecord::Migration[8.1]
  def change
    add_column :artists, :avatar_url, :string
  end
end
