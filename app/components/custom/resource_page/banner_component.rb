class ResourcePage::BannerComponent < ApplicationComponent
  attr_reader :resource

  def initialize(resource: )
    @resource = resource
  end

  def resource_class
    "-#{@resource.class.name.downcase}"
  end

  def banner_inline_style
    helpers.sentiment_color_style(@resource.sentiment)
  end
end
