class ArtistsController < ApplicationController
  def index
    @artists = Artist.includes(:tracks).order(:name)
    @starsinger_only = params[:source] == "starsinger"
    @artists = @artists.where.not(starsinger_id: nil) if @starsinger_only
  end

  def show
    @artist = Artist.find(params[:id])
    @tracks = @artist.tracks.order(:id)
    render "tracks/list"
  end
end
