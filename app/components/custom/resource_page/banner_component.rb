class ResourcePage::BannerComponent < ApplicationComponent
  attr_reader :resource

  def initialize(resource: )
    @resource = resource
  end

  def resource_class
    "-#{@resource.class.name.downcase}"
  end

  def banner_inline_style
    if @resource.sentiment.present?
      "background-color:#{@resource.sentiment.color};color: #{helpers.pick_text_color(@resource.sentiment.color)}"
    end
  end
end
