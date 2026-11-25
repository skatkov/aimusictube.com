class PlaylistEntriesController < ApplicationController
  def create
    track = Track.find(params[:track_id])
    playlist = playlists.find(params.expect(:playlist_id))
    playlist.playlist_entries.create_or_find_by!(track: track)
    redirect_to watch_path(track.youtube_id), notice: "Saved to #{playlist.name}.", status: :see_other
  end

  def destroy
    playlist = playlists.find(params[:playlist_id])
    playlist.playlist_entries.find(params[:id]).destroy!
    redirect_to playlist, status: :see_other
  end
end
