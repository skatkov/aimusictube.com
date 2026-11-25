class LikesController < ApplicationController
  def index
    @title = "Liked tracks"
    @description = "Your favorites, saved in this browser."
    @empty = "No likes yet. Open a track and select Like."
    @tracks = paginate(Like.where(browser_key: browser_key).order(id: :desc)).includes(track: :artist).map(&:track)
    render "tracks/list"
  end

  def create
    track = Track.find(params[:track_id])
    Like.create_or_find_by!(browser_key: browser_key, track: track)
    redirect_to track, status: :see_other
  end

  def destroy
    track = Track.find(params[:track_id])
    Like.where(browser_key: browser_key, track: track).delete_all
    redirect_to track, status: :see_other
  end
end
