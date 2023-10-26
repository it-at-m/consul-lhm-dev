class Shared::OfficialPositionBadgeComponent < ApplicationComponent
  attr_reader :user

  def initialize(user:)
    @user = user
  end

  def render?
    user.official_position.present?
  end
end
