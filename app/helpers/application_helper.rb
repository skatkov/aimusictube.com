module ApplicationHelper
  def icon(name)
    tag.svg(viewBox: "0 0 24 24", class: "icon", "aria-hidden": true, focusable: false) do
      tag.use(href: "/icons.svg##{name}")
    end
  end

  def nav_link(label, path, active:, glyph: nil)
    content = glyph ? safe_join([ icon(glyph), tag.span(label) ]) : label
    link_to content, path, aria: { current: ("location" if active) }
  end

  def channel_avatar(artist)
    content = artist.avatar_url.present? ? image_tag(artist.avatar_url, alt: "", loading: "lazy", referrerpolicy: "no-referrer") : artist.name.first
    tag.span(content, class: "avatar", aria: { hidden: true })
  end

  def sidebar_artists
    @sidebar_artists ||= Artist.order(:name).limit(6).to_a
  end
end
