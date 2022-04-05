class Topics::CommentsFormComponent < ApplicationComponent
  delegate :current_user, :user_signed_in?, to: :helpers

  def initialize(topic)
    @topic = topic
  end
end
