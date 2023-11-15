# frozen_string_literal: true

class Shared::NotificationsComponent < ApplicationComponent
  def initialize(notifiable:, author: nil)
    @notifiable = notifiable
    @author = author
  end

  def notifications
    if @notifiable.is_a?(ProjektPhase::ProjektNotificationPhase)
      @notifications ||= @notifiable.projekt_notifications

    elsif @notifiable.is_a?(Proposal)
      @notifications ||= @notifiable.proposal_notifications

    else
      @notifications ||= []
    end
  end

  def opened_by_default?
    @notifiable.is_a?(Proposal)
  end
end
