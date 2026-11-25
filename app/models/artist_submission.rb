class ArtistSubmission < ApplicationRecord
  normalizes :youtube_url, with: ->(url) { url.strip }
  validates :youtube_url, length: { maximum: 2048 }, format: {
    with: %r{
      \Ahttps?://(?:
        (?:www\.)?youtu\.be/[\w-]{11} |
        (?:(?:www|m|music)\.)?youtube\.com/(?:
          watch\?(?:[^\s\\#]*&)?v=[\w-]{11} |
          (?:shorts|live)/[\w-]{11} |
          (?:@|(?:channel|c|user)/)[^/?\#\s\\]+(?:/[^\s\\?#]*)?
        )
      )(?:[?&#][^\s\\]*)?\z
    }ix,
    message: "Enter a YouTube video or channel link."
  }
  validates :notes, length: { maximum: 1000 }
end
