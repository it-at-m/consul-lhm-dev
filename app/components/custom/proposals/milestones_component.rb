# frozen_string_literal: true

class Proposals::MilestonesComponent < ApplicationComponent
  def initialize(milestones:, milestoneable:)
    @milestones = milestones
    @milestoneable = milestoneable
  end
end
