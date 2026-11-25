# AI Music Tube

<!-- impeccable:product-schema 1 -->

## Platform

web

## Stack

Rails, Hotwire, and SQLite.

## Product purpose

Help listeners discover artists making music with AI, find tracks, and keep a private library. HackerTube is the reference for browsing and library navigation.

## Capabilities and constraints

- Show **AI-generated** and **AI-assisted** labels on track pages when there is evidence about the audio or composition. Keep upload-wide disclosures and reader picks without audio evidence in the catalog with a source note and no label.
- Play on the track page through the official YouTube embed, with a direct link-out fallback. The app does not host audio or video.
- Likes, history, and playlists belong to the current browser; no login or cross-device sync. History records a play click or a direct open, not listening time.
- Start with a curated catalog and test locally before considering deployment.

## Design commitment

“It should look and feel like YouTube.” Use HackerTube as the concrete reference for the feed, search header, navigation drawer, library and watch-page layout. Familiarity takes priority over a new visual identity.

Use the project's own mark. The site-wide footer credits the builders and states that the project is not affiliated with or endorsed by YouTube or Google. About also explains this independence.
