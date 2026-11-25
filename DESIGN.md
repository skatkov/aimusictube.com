---
name: AI Music Tube
description: A familiar video feed with an independent music identity.
colors:
  record-teal: "#096b65"
  light-background: "#ffffff"
  dark-background: "#0f0f0f"
  light-layer: "#f2f2f2"
  dark-layer: "#272727"
  light-text: "#0f0f0f"
  dark-text: "#f1f1f1"
  light-secondary-text: "#606060"
  dark-secondary-text: "#aaaaaa"
  overlay-scrim: "rgb(0 0 0 / .45)"
  duration-scrim: "rgb(0 0 0 / .82)"
  play-hover: "#333"
  light-error: "#ac172c"
  dark-error: "#ffb4bd"
typography:
  headline:
    fontSize: "28px"
  watch-title:
    fontSize: "21px"
  section-title:
    fontSize: "18px"
  body:
    fontFamily: "Roboto, Segoe UI, Arial, sans-serif"
    fontSize: "14px"
    lineHeight: 1.43
  title:
    fontFamily: "Roboto, Segoe UI, Arial, sans-serif"
    fontSize: "16px"
    fontWeight: 600
    lineHeight: "22px"
  avatar-initial:
    fontSize: "15px"
  secondary-copy:
    fontSize: "13px"
  compact-metadata:
    fontSize: "12px"
  compact-navigation:
    fontSize: "10px"
rounded:
  badge: "4px"
  chip: "8px"
  nav-item: "10px"
  thumbnail: "12px"
  mobile-save-panel: "16px"
  pill: "24px"
components:
  filter-chip:
    backgroundColor: "{colors.light-layer}"
    textColor: "{colors.light-text}"
    rounded: "{rounded.chip}"
    height: "32px"
  library-action:
    backgroundColor: "{colors.light-layer}"
    textColor: "{colors.light-text}"
    rounded: "{rounded.pill}"
---

# Design System: AI Music Tube

## Overview

Use the familiar video-feed conventions seen in HackerTube and YouTube, without borrowing YouTube’s logo. The teal record is the app’s mark. Thumbnails, not the interface, provide most of the color.

## Colors

The shell and content share one neutral canvas. Muted text carries secondary metadata; selected chips invert foreground and background. Light and dark modes retain the same hierarchy.

## Typography

The shell, cards, and library use the same sans-serif stack. Track titles are two lines at most on cards and unrestricted on the watch page.

## Layout

Use a 56px sticky masthead and a 240px sidebar on desktop. The sidebar remembers its desktop size, shrinks at 1100px and becomes a drawer below 800px. Keep just Discover, Most played, and Browse tags above the feed. On the Tags page, counted tags wrap onto new lines. Feed columns fit thumbnails at least 300px wide until the single-column breakpoint at 600px.

## Elevation & Depth

Keep the feed flat. Use tonal surfaces for chips and disclosure; reserve a shadow for the opened Save panel.

## Shapes

Thumbnails use a 16:9 crop and a 12px radius. Pill shapes are for actions; use the smaller chip radius for filters.

## Components

- **Feed:** Put duration in the bottom-right corner of each thumbnail and put the title, artist, and genre below.
- **Player:** Start with a poster and a centered, icon-only play control. Activating it loads the official YouTube iframe. Keep **Watch on YouTube** available outside the player.
- **Disclosure:** Keep the label in text, not just color. Link to the evidence or the source checked on the track page.
- **Footer:** Center the builder credit, X profile link, and YouTube/Google independence disclosure together. Let them wrap on narrow screens.

## Do's and Don'ts

- Do use the teal record in the header, drawer, and favicon. YouTube branding can appear inside its own player, not as the catalog’s mark.
- Do use YouTube thumbnails and channel avatars with their original source URLs. The app ships no raster artwork.
- Omit the label and its separator when a source does not establish AI use in the music.
