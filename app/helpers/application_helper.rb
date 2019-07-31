module ApplicationHelper
  def code_regexp
    /^[a-f0-9]{64}$/
  end

  def host_from(url)
    Addressable::URI.parse(url).host
  end

  def normalize_url(url)
    Addressable::URI.parse(url).normalize.to_s
  end

  def render_alert(**locals)
    respond_to do |format|
      format.html { partial :'shared/alert', locals: locals }
      format.json { json error: locals[:error], error_description: "#{locals[:error_title]}: #{locals[:error_description]}" }
    end
  end

  def uri_regexp
    %r{^https?://.*}
  end
end
