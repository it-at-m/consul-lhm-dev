# frozen_string_literal: true

class Shared::ResourceItemComponent < ApplicationComponent
  renders_one :header_content
  renders_one :image_overlay_item
  renders_many :additional_body_sections
  renders_many :footer_items

  DATE_FORMAT = "%d.%m.%Y".freeze

  def initialize(
    resource: nil,
    projekt: nil,
    title:,
    description:,
    card_image_url: nil,
    horizontal_image_url: nil,
    author: nil,
    wide: false,
    id: nil,
    subline: nil,
    url: nil,
    tags: [],
    image_placeholder_icon_class: "fa-file"
  )
    @resource = resource
    @title = title
    @projekt = projekt
    @description = description
    @card_image_url = card_image_url
    @horizontal_image_url = horizontal_image_url
    @author = author
    @wide = wide
    @url = url
    @subline = subline
    @tags = tags
    @resource_name = @resource.class.name.downcase.gsub("::", "_")
    @image_placeholder_icon_class = image_placeholder_icon_class

    @id = id
  end

  def component_class_name
    class_name = "#{@resource_name&.underscore}-list-item"

    if @wide
      class_name += " -wide"
    end

    class_name
  end

  def days_left
    if @end_date.present?
      "Noch #{(@end_date - Date.today).to_i} Tage"
    end
  end

  def date
    @date&.strftime(DATE_FORMAT)
  end

  def truncate_length
    if @wide
      150
    else
      120
    end
  end
end
