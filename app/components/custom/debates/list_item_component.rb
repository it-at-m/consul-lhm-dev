# frozen_string_literal: true

class Debates::ListItemComponent < ApplicationComponent
  attr_reader :debate

  def initialize(debate:, wide: false)
    @debate = debate
    @wide = wide
  end

  def component_attributes
    {
      resource: @debate,
      projekt: debate.projekt,
      title: debate.title,
      description: debate.description,
      tags: debate.tags.first(3),
      wide: @wide,
      url: helpers.debate_path(debate),
      card_image_url: debate.image&.variant(:medium),
      horizontal_card_image_url: debate.image&.variant(:medium),
      image_placeholder_icon_class: "fa-comments",
      author: debate.author
    }
  end

  def date_formated
    l(debate.created_at, format: :date_only)
  end
end
