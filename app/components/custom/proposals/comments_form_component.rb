class Proposals::CommentsFormComponent < ApplicationComponent
  delegate :current_user, :user_signed_in?, to: :helpers

  def initialize(proposal)
    @proposal = proposal
    @projekt = proposal.projekt
  end
end
