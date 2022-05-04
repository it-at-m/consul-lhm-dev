class DeficiencyReports::CommentsFormComponent < ApplicationComponent
  delegate :current_user, :user_signed_in?, :link_to_verify_account, to: :helpers

  def initialize(deficiency_report)
    @deficiency_report = deficiency_report
  end
end
