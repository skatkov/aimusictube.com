class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  private

  def browser_key
    session[:browser_key] ||= SecureRandom.uuid
  end

  def playlists
    Playlist.where(browser_key: browser_key)
  end
end
