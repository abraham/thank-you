module ApplicationHelper
  include Twitter::Autolink

  def link_tweet_text(text)
    white_list_sanitizer = Rails::Html::WhiteListSanitizer.new
    unsafe_html = auto_link(text)
    safe_html = white_list_sanitizer.sanitize(unsafe_html, tags: ['a'], attributes: ['href']).html_safe
    safe_html
  end
end
