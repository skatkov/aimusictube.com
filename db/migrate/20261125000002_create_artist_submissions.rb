class CreateArtistSubmissions < ActiveRecord::Migration[8.1]
  def change
    create_table :artist_submissions do |t|
      t.string :youtube_url, null: false
      t.text :notes
      t.timestamps
    end
  end
end
