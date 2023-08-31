# frozen_string_literal: true

class Proposals::NotificationsComponent < ApplicationComponent
  def initialize(notifications:, author:)
    @notifications = notifications
    @author = author
  end
end
