# frozen_string_literal: true

class Shared::ResourceImageComponent < ApplicationComponent
  def initialize(image_url:, resource:, image_placeholder_icon_class:)
    @image_url = image_url
    @resource = resource
    @image_placeholder_icon_class = image_placeholder_icon_class
  end

  def resource_name
    if @resource.is_a?(Poll) && @resource.author.present?
      @resource.model_name.human
    elsif @resource.respond_to?(:projekt_phase) && @resource.projekt_phase.present?
      @resource.projekt_phase.title
    else
      @resource.model_name.human
    end
  end

  def alt_text
    return "" unless @resource.respond_to?(:title)

    @resource.class.model_name.human + ": " + @resource.title
  end
end
