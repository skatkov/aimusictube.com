class HistoryController < ApplicationController
  def show
    @title = "History"
    @description = "Tracks you opened in the player or on YouTube from this browser."
    @empty = "Nothing here yet. Play a track or open it on YouTube to start your history."
    @tracks = Play.where(browser_key: browser_key).order(opened_at: :desc, id: :desc).includes(track: :artist).map(&:track)
    render "tracks/list"
  end

  def destroy
    Play.where(browser_key: browser_key).delete_all
    redirect_to history_path, status: :see_other
  end
end
