# Lists artists and their discographies.
class ArtistsController < ApplicationController
  def index
    @artists = Artist.order(:name)
    @track_counts = Track.group(:artist_id).size
    @starsinger_only = params[:source] == "starsinger"
    @artists = @artists.where.not(starsinger_id: nil) if @starsinger_only
  end

  def show
    @artist = Artist.find(params.expect(:id))
    @tracks = paginate(@artist.tracks.order(:id))
    render "tracks/list"
  end
end
