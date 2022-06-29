class ProjektQuestions::CommentsFormComponent < ApplicationComponent
  delegate :current_user, :user_signed_in?, :link_to_verify_account, to: :helpers

  def initialize(projekt_question)
    @projekt_question = projekt_question
    @projekt = projekt_question.projekt
  end
end
