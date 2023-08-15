# frozen_string_literal: true

class Polls::ListItemComponent < ApplicationComponent
  attr_reader :poll

  def initialize(poll:)
    @poll = poll
  end

  def component_attributes
    {
      resource: @poll,
      projekt: poll.projekt,
      title: poll.title,
      description: poll.summary,
      # tags: poll.tags.first(3),
      # sdgs: poll.related_sdgs.first(5),
      # start_date: poll.total_duration_start,
      # end_date: poll.total_duration_end,
      url: helpers.poll_path(poll),
      card_image_url: poll.image&.variant(:medium),
      horizontal_card_image_url: poll.image&.variant(:medium),
      # date: poll.created_at,
      image_placeholder_icon_class: "fa-vote-yea"
    }
  end
end
