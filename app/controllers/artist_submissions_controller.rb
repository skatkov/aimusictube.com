class ArtistSubmissionsController < ApplicationController
  def new
    @submission = ArtistSubmission.new
  end

  def create
    @submission = ArtistSubmission.new(params.expect(artist_submission: %i[youtube_url notes]))
    if @submission.save
      redirect_to artists_path, notice: "Thanks! Your artist suggestion is saved for review.", status: :see_other
    else
      render :new, status: :unprocessable_content
    end
  end
end
