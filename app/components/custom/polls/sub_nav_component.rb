# frozen_string_literal: true

class Polls::SubNavComponent < ApplicationComponent
  attr_reader :poll
  delegate :can?, :results_menu?, :stats_menu?, :info_menu?, to: :helpers

  def initialize(poll:)
    @poll = poll
  end

  def render?
    can?(:stats, poll) || can?(:results, poll)
  end
end
