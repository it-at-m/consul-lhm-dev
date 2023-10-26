# frozen_string_literal: true

class Users::ProfileBannerComponent < ApplicationComponent
  delegate :skip_user_verification?, to: :helpers

  def initialize(user:, edit_mode: false)
    @user = user
    @edit_mode = edit_mode
  end
end
