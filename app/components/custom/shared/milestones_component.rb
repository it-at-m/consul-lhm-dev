# frozen_string_literal: true

class Shared::MilestonesComponent < ApplicationComponent
  def initialize(milestones:, milestoneable:)
    @milestones = milestones
    @milestoneable = milestoneable
  end

  def ordered_milestones
    return @milestones unless @milestoneable.is_a?(ProjektPhase::MilestonePhase)

    order = @milestoneable.settings.find_by(key: "feature.general.newest_first").value.present? ? :desc : :asc
    @milestones.order_by_publication_date(order)
  end

  def opened_by_default?
    @milestoneable.is_a?(Proposal)
  end
end
