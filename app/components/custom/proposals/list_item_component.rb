# frozen_string_literal: true

class Proposals::ListItemComponent < ApplicationComponent
  attr_reader :proposal

  def initialize(proposal:, voted:)
    @proposal = proposal
    @sentiment = proposal.sentiment
    @voted = voted
  end

  def component_attributes
    {
      resource: @proposal,
      projekt: proposal.projekt,
      title: proposal.title,
      description: proposal.description,
      header_style: header_style,
      tags: proposal.tags.first(3),
      url: helpers.proposal_path(proposal),
      image_url: proposal.image&.variant(:card_thumb),
      image_placeholder_icon_class: "fa-lightbulb",
      no_footer_bottom_padding: true
    }
  end

  def date_formated
    return if proposal.published_at.nil?

    l(proposal.published_at, format: :date_only)
  end

  def header_style
    helpers.sentiment_color_style(@sentiment)
  end
end
