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
      description: (poll.summary.presence || poll.description),
      url: helpers.poll_path(poll),
      image_url: poll.image&.variant(:card_thumb),
      image_placeholder_icon_class: "fa-vote-yea"
    }
  end
end
