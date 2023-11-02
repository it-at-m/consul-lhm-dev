class ResourcePage::BannerComponent < ApplicationComponent
  renders_one :links_section
  attr_reader :resource

  def initialize(resource:, compact: false)
    @resource = resource
    @compact = compact
  end

  def resource_class
    base_class = "-#{@resource.class.name.split("::").last.downcase}"

    if @resource.image.present?
      base_class += " -with-image"
    end

    if @compact
      base_class += " -compact"
    end

    base_class
  end

  def banner_inline_style
    return "" unless @resource.respond_to?(:sentiment)

    helpers.sentiment_color_style(@resource.sentiment)
  end
end
