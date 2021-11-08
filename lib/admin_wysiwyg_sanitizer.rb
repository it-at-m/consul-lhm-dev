class AdminWYSIWYGSanitizer < WYSIWYGSanitizer
  def allowed_tags
    super + %w[
      h1 iframe object param embed
      i input label form button figure figcaption nav
    ]
  end

  def allowed_attributes
    super + %w[
      frameborder height width longdesc scrolling title allow allowfullscreen value
      dir
      role tabindex type for name title
      data-toggle aria-label aria-hidden allowfullscreen
      data-slider data-initial-start data-end data-slider-handle data-slider-fill
      data-dropdown-menu
      data-magellan data-magellan-target
      data-drilldown
      data-accordion data-accordion-item data-tab-content
      data-accordion-menu
      data-dropdown data-auto-focus placeholder
      data-reveal data-open data-close
      data-tabs aria-selected data-tabs-target data-tabs-content
      data-orbit data-slide data-slide-active-label
      aria-valuenow aria-valuemin aria-valuemax aria-valuetext
      data-tooltip
    ]
  end
end
