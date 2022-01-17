class DeficiencyReports::CommentsFormComponent < ApplicationComponent
  delegate :current_user, :user_signed_in?, to: :helpers

  def initialize(deficiency_report)
    @deficiency_report = deficiency_report
  end
end
