class Polls::CommentsFormComponent < ApplicationComponent
  delegate :current_user, :user_signed_in?, to: :helpers

  def initialize(poll)
    @poll = poll
  end
end
