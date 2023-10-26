class Projekts::CommentsFormComponent < ApplicationComponent
  delegate :current_user, :user_signed_in?, :link_to_verify_account, to: :helpers

  def initialize(special_projekt)
    @special_projekt = special_projekt
  end
end
