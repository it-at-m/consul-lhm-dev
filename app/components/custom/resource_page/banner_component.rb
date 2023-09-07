class ResourcePage::BannerComponent < ApplicationComponent
  renders_one :links_section
  attr_reader :resource

  def initialize(resource: )
    @resource = resource
  end

  def resource_class
    "-#{@resource.class.name.downcase}"
  end

  def banner_inline_style
    if @resource.respond_to?(:sentiment) && @resource.sentiment.present?
      "background-color:#{@resource.sentiment.color};color: #{helpers.pick_text_color(@resource.sentiment.color)}"
    end
  end
end
