# frozen_string_literal: true

class Users::ProfileBannerComponent < ApplicationComponent
  def initialize(user:, imageable: nil, image_builder: nil)
    @user = user
    @image_builder = image_builder
    @imageable = imageable
  end
end
