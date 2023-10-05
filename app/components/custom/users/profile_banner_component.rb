# frozen_string_literal: true

class Users::ProfileBannerComponent < ApplicationComponent
  def initialize(user:, imageable: nil, image_builder: nil, edit_image: false)
    @user = user
    @image_builder = image_builder
    @imageable = imageable
    @edit_image = edit_image
  end
end
