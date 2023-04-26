class Budgets::Investments::CommentsFormComponent < ApplicationComponent
  delegate :current_user, :user_signed_in?, :link_to_verify_account, :link_to_signin, :link_to_signup, to: :helpers

  def initialize(investment)
    @investment = investment
  end

  private
    def reason
      @reason ||= @investment.permission_problem(current_user)
    end

    def commenting_allowed?
      reason.blank?
    end

    def cannot_comment_reason
      t("custom.comments.restricted.#{reason}",
        signin: link_to_signin,
        signup: link_to_signup,
        verify_account: link_to_verify_account,
        city: Setting["org_name"],
        geozones: @investment.budget.budget_phase.geozone_restrictions_formatted,
        age_restriction: @investment.budget.budget_phase.age_restriction_formatted,
        restricted_streets: @investment.budget.budget_phase.street_restrictions_formatted
       )
    end
end
