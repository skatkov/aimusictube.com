# Browses tracks and records playback requests.
class TracksController < ApplicationController
  def index
    @query = params[:q].to_s.strip.first(100)
    genre = params[:genre]
    genre = "Mixes" if genre == "Jazz mixes"
    @genre = genre if genre.is_a?(String) && Track.exists?(genre: genre)
    kind = params[:kind]
    @kind = kind if Track::LABELS.key?(kind)
    @sort = "most_played" if params[:sort] == "most_played"
    @tracks = Track.includes(:artist)
    @tracks = @tracks.where(genre: @genre) if @genre
    @tracks = @tracks.where(kind: @kind) if @kind
    @tracks = @tracks.order(play_count: :desc) if @sort
    if @query.present?
      term = "%#{Track.sanitize_sql_like(@query.downcase(:fold), "!")}%"
      @tracks = @tracks.joins(:artist).where("tracks.search_text LIKE :q ESCAPE '!' OR artists.search_name LIKE :q ESCAPE '!'", q: term).order(:title, :id)
    else
      # Mix artists so a run of uploads from one channel doesn't fill the front page.
      @tracks = @tracks.order(Arel.sql("ROW_NUMBER() OVER (PARTITION BY tracks.artist_id ORDER BY tracks.id), tracks.id"))
    end
    @tracks = paginate(@tracks)
    @empty = "No tracks match. Try another search or AI filter."
  end

  def legacy
    redirect_to Track.find(params[:id]), status: :moved_permanently
  end

  def show
    @track = Track.find_by!(youtube_id: params[:youtube_id])
    @liked = Like.exists?(browser_key: browser_key, track: @track)
    @playlists = playlists.order(:name)
    @more_tracks = Track.where.not(id: @track.id).includes(:artist)
      .in_order_of(:artist_id, [ @track.artist_id ], filter: false)
      .in_order_of(:genre, [ @track.genre ], filter: false).order(:title).limit(8)
  end

  def play
    track = Track.find(params[:id])
    Track.transaction do
      Play.upsert({ browser_key: browser_key, track_id: track.id, opened_at: Time.current },
        unique_by: %i[browser_key track_id])
      track.increment!(:play_count)
    end

    if turbo_frame_request?
      render partial: "tracks/player", locals: { track: track, playing: true }
    else
      redirect_to track.youtube_url, allow_other_host: true, status: :see_other
    end
  end
end
