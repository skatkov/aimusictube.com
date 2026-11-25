class PlaylistsController < ApplicationController
  before_action :load_track, only: %i[index create]

  def index
    @playlists = playlists.order(:name)
    @playlist = Playlist.new
  end

  def show
    @playlist = playlists.find(params[:id])
    @entries = paginate(@playlist.playlist_entries.order(:id)).includes(track: :artist)
  end

  def create
    @playlist = playlists.build(params.expect(playlist: [ :name ]))
    @playlist.playlist_entries.build(track: @track) if @track
    if @playlist.save
      redirect_to @playlist, status: :see_other
    else
      @playlists = playlists.order(:name)
      render :index, status: :unprocessable_content
    end
  end

  def destroy
    playlists.find(params[:id]).destroy!
    redirect_to playlists_path, status: :see_other
  end

  private

  def load_track
    @track = Track.find(params.expect(:track_id)) if params.key?(:track_id)
  end
end
