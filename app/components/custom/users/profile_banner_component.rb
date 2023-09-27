# frozen_string_literal: true

class Users::ProfileBannerComponent < ApplicationComponent
  def initialize(user:)
    @user = user
  end
end
