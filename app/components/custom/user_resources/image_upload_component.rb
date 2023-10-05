class UserResources::ImageUploadComponent < ApplicationComponent
  def initialize(f, imageable:)
    @f = f
    @imageable = imageable
  end
end
