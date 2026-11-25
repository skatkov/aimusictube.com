# Shares browser-scoped library access and pagination across catalog pages.
class ApplicationController < ActionController::Base
  PAGE_SIZE = 48

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  private

  def paginate(scope)
    @result_count = scope.size
    @pages = [ 1, (@result_count + PAGE_SIZE - 1) / PAGE_SIZE ].max
    @page = params[:page].to_s.to_i.clamp(1, @pages)
    scope.limit(PAGE_SIZE).offset((@page - 1) * PAGE_SIZE)
  end

  def browser_key
    session[:browser_key] ||= SecureRandom.uuid
  end

  def playlists
    Playlist.where(browser_key: browser_key)
  end
end
