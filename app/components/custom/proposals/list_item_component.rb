# frozen_string_literal: true

class Proposals::ListItemComponent < ApplicationComponent
  attr_reader :proposal

  def initialize(proposal:, wide: false)
    @proposal = proposal
    @wide = wide
    @sentiment = proposal.sentiment
  end

  def component_attributes
    {
      resource: @proposal,
      projekt: proposal.projekt,
      title: proposal.title,
      description: proposal.description,
      header_style: header_style,
      tags: proposal.tags.first(3),
      wide: @wide,
      url: helpers.proposal_path(proposal),
      card_image_url: proposal.image&.variant(:medium),
      horizontal_card_image_url: proposal.image&.variant(:medium),
      image_placeholder_icon_class: "fa-lightbulb",
      author: proposal.author
    }
  end

  def date_formated
    l(proposal.published_at, format: :date_only)
  end

  def header_style
    return nil if @sentiment.nil?

    "background-color:#{@sentiment.color};"
  end
end
