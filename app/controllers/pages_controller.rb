# Renders the catalog statistics and tag directory.
class PagesController < ApplicationController
  def about
    @track_count = Track.count
    @genre_count = Track.distinct.count(:genre)
    @artist_count = Artist.count
  end

  def tags
    @query = params[:q].to_s.strip.first(100)
    @sort = "most_played" if params[:sort] == "most_played"
    @disclosure_counts = Track.group(:kind).count
    @genre_counts = Track.group(:genre).order(:genre).count
  end
end
