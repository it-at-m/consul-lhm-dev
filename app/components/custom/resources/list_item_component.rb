# frozen_string_literal: true

class Resources::ListItemComponent < ApplicationComponent
  renders_one :header
  renders_one :image_overlay_item
  renders_many :additional_body_sections
  renders_many :footer_sections

  def initialize(
    title:,
    description:,
    resource: nil,
    projekt: nil,
    image_url: nil,
    subline: nil,
    url: nil,
    tags: [],
    image_placeholder_icon_class: "fa-file",
    header_style: nil,
    narrow_header: false,
    date: nil,
    no_footer_bottom_padding: false
  )
    @title = title
    @projekt = projekt
    @description = description
    @resource = resource
    @image_url = image_url
    @url = url
    @subline = subline
    @tags = tags
    @image_placeholder_icon_class = image_placeholder_icon_class
    @header_style = header_style
    @narrow_header = narrow_header
    @date = date
    @no_footer_bottom_padding = no_footer_bottom_padding
  end

  def component_class_name
    class_name = "#{@resource.class.name&.underscore}-list-item"
    # class_name = "-list-item"

    if @wide
      class_name += " -wide"
    end

    if header.blank?
      class_name += " -no-header"
    end

    class_name
  end

  def days_left
    if @end_date.present?
      "Noch #{(@end_date - Date.today).to_i} Tage"
    end
  end

  def date
    return if @date.blank?

    l(@date, format: :date_only)
  end

  def truncate_length
    if @wide
      150
    else
      120
    end
  end

  def header_class
    if @narrow_header
      "-narrow"
    end
  end

  def show_author_name?
    @resource.is_a?(Debate) ||
      @resource.is_a?(Proposal) ||
      @resource.is_a?(Budget::Investment) ||
      @resource.is_a?(DeficiencyReport) ||
      @resource.is_a?(Topic)
  end

  def on_behalf_of?
    return unless show_author_name?

    @resource.on_behalf_of.present?
  end
end
