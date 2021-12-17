class WYSIWYGSanitizer
  def allowed_tags
    %w[ div p ul ol li blockquote br hr a h2 h3 h4 h5 h6 strong em u s sub sup span img
    table caption thead tr th tbody td abbr
  ]
  end

  def allowed_attributes
    %w[
      href style target class id name alt src align border cellpadding cellspacing summary scope title
    ]
  end

  def sanitize(html)
    ActionController::Base.helpers.sanitize(html, tags: allowed_tags, attributes: allowed_attributes)
  end
end
