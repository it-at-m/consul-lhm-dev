# frozen_string_literal: true

class Projekts::ListItemComponent < ApplicationComponent
  attr_reader :projekt

  def initialize(projekt:, wide: false)
    @projekt = projekt
    @wide = wide
  end

  def component_attributes
    {
      resource: projekt,
      title: projekt.page.title,
      description: projekt.description,
      tags: projekt.tags.first(3),
      sdgs: projekt.related_sdgs.first(5),
      start_date: projekt.total_duration_start,
      end_date: projekt.total_duration_end,
      wide: @wide,
      url: projekt.page.url,
      image_url: projekt.image&.variant(:medium),
      id: projekt.id
    }
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
