class Budgets::NewButtonComponent < ApplicationComponent
  delegate :can?, :current_user, :user_signed_in?, :sanitize, :link_to_verify_account, :link_to_signin, :link_to_signup, to: :helpers

  def initialize(budget)
    @budget = budget
	end

  private

  def reason_for_not_allowing_new_proposal
    @budget.reason_for_not_allowing_new_proposal(current_user)
	end
end
