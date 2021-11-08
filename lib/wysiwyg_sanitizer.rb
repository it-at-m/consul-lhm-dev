class WYSIWYGSanitizer
  def allowed_tags
    %w[ p ul ol li strong em u s a h1 h2 h3 h4 h5 h6 div span img iframe br i ]
  end

  def allowed_attributes
    %w[
      href style class id target width height
      data-slider data-initial-start data-end data-slider-handle role tabindex data-slider-fill type
      data-dropdown-menu
      data-drilldown
      data-accordion-menu
      allowfullscreen
    ]
  end

  def sanitize(html)
    ActionController::Base.helpers.sanitize(html, tags: allowed_tags, attributes: allowed_attributes)
  end
end
