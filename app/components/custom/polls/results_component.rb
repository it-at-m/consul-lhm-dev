# frozen_string_literal: true

class Polls::ResultsComponent < ApplicationComponent
  attr_reader :poll
  delegate :can?, to: :helpers

  def initialize(poll:)
    @poll = poll
  end

  def render?
    can?(:results, poll)
  end
end
