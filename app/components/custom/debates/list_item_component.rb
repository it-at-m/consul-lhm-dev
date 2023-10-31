# frozen_string_literal: true

class Debates::ListItemComponent < ApplicationComponent
  attr_reader :debate

  def initialize(debate:)
    @debate = debate
  end

  def component_attributes
    {
      resource: @debate,
      projekt: debate.projekt,
      title: debate.title,
      description: debate.description,
      tags: debate.tags.first(3),
      url: helpers.debate_path(debate),
      image_url: debate.image&.variant(:card_thumb),
      image_placeholder_icon_class: "fa-comments",
      no_footer_bottom_padding: true
    }
  end

  def date_formated
    l(debate.created_at, format: :date_only)
  end
end
