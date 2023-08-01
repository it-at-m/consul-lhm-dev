# frozen_string_literal: true

class Shared::ResourceImageComponent < ApplicationComponent
  def initialize(image_url:, resource_name:, image_placeholder_icon_class:)
    @image_url = image_url
    @resource_name = resource_name
    @image_placeholder_icon_class = image_placeholder_icon_class
  end
end
