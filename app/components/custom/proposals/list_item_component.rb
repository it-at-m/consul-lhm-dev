# frozen_string_literal: true

class Proposals::ListItemComponent < ApplicationComponent
  attr_reader :proposal

  def initialize(proposal:, wide: false)
    @proposal = proposal
    @wide = wide
  end

  def component_attributes
    {
      resource: @proposal,
      projekt: proposal.projekt,
      title: proposal.title,
      description: proposal.summary,
      tags: proposal.tags.first(3),
      # sdgs: proposal.related_sdgs.first(5),
      # start_date: proposal.total_duration_start,
      # end_date: proposal.total_duration_end,
      wide: @wide,
      url: helpers.proposal_path(proposal),
      card_image_url: proposal.image&.variant(:medium),
      horizontal_image_url: proposal.image&.variant(:medium),
      # date: proposal.created_at,
      image_placeholder_icon_class: "fa-lightbulb",
      author: proposal.author,
      id: proposal.id
    }
  end
end
