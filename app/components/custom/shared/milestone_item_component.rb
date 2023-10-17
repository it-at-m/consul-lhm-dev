# frozen_string_literal: true

class Shared::MilestoneItemComponent < ApplicationComponent
  attr_reader :milestone

  def initialize(milestone:)
    @milestone = milestone
  end
end
