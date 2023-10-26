class Sidebar::ResourceAuthorComponent < ApplicationComponent
  attr_reader :user

  delegate :skip_user_verification?, to: :helpers

  def initialize(user:)
    @user = user
  end
end
