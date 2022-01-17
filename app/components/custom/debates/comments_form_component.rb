class Debates::CommentsFormComponent < ApplicationComponent
  delegate :current_user, :user_signed_in?, to: :helpers

  def initialize(debate)
    @debate = debate
    @projekt = debate.projekt
  end
end
