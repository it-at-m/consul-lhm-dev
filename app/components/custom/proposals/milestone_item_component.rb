# frozen_string_literal: true

class Proposals::MilestoneItemComponent < ApplicationComponent
  attr_reader :milestone

  def initialize(milestone:)
    @milestone = milestone
  end
end
