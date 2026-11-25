Rails.application.config.session_store :cookie_store,
  key: "_ai_music_tube", expire_after: 1.year, same_site: :lax
