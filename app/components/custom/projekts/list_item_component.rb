# frozen_string_literal: true

class Projekts::ListItemComponent < ApplicationComponent
  attr_reader :projekt

  def initialize(projekt:)
    @projekt = projekt
  end

  def component_attributes
    {
      resource: projekt,
      title: projekt.page.title,
      description: strip_tags(projekt.page.subtitle),
      tags: projekt.tags,
      narrow_header: true,
      url: projekt.page.url,
      image_url: image_variant(:card_thumb),
    }
  end

  def projekt_phase_url_for(phase)
    "#{projekt.page.url}?projekt_phase_id=#{phase.id}#projekt-footer"
  end

  def image_variant(variant)
    projekt.image&.variant(variant)
  end

  def date_formated
    base_formated_date = helpers.format_date_range(projekt.total_duration_start, projekt.total_duration_end)

    base_formated_date.presence || "Fortlaufendes Projekt"
  end

  def phase_icon_class(phase)
    case phase
    when ProjektPhase::CommentPhase
      "fa-comment-dots"
    when ProjektPhase::DebatePhase
      "fa-comments"
    when ProjektPhase::ProposalPhase
      "fa-lightbulb"
    when ProjektPhase::QuestionPhase
      "fa-poll-h"
    when ProjektPhase::BudgetPhase
      "fa-euro-sign"
    when ProjektPhase::VotingPhase
      "fa-vote-yea"
    when ProjektPhase::LegislationPhase
      "fa-file-word"
    when ProjektPhase::ArgumentPhase
      "fa-user-tie"
    when ProjektPhase::NewsfeedPhase
      "fa-newspaper"
    when ProjektPhase::MilestonePhase
      "fa-tasks"
    when ProjektPhase::EventPhase
      "fa-calendar-alt"
    when ProjektPhase::LivestreamPhase
      "fa-video"
    when ProjektPhase::ProjektNotificationPhase
      "fa-bell"
    end
  end
end
