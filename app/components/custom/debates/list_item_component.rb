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
      sdgs: debate.related_sdgs.first(5),
      # start_date: debate.total_duration_start,
      # end_date: debate.total_duration_end,
      wide: @wide,
      url: helpers.debate_path(debate),
      image_url: debate.image&.variant(:medium),
      date: debate.created_at,
      image_placeholder_icon_class: "fa-comments",
      author: debate.author,
      id: debate.id
    }
  end
end
