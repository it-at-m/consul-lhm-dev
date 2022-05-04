class Topics::CommentsFormComponent < ApplicationComponent
  delegate :current_user, :user_signed_in?, :link_to_verify_account, to: :helpers

  def initialize(topic)
    @topic = topic
  end
end
