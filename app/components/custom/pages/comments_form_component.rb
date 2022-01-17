class Pages::CommentsFormComponent < ApplicationComponent
  delegate :current_user, :user_signed_in?, to: :helpers

  def initialize(projekt)
    @projekt = projekt
  end
end
