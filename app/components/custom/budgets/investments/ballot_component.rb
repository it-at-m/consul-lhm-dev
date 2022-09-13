require_dependency Rails.root.join("app", "components", "budgets", "investments", "ballot_component").to_s

class Budgets::Investments::BallotComponent < ApplicationComponent
  delegate :link_to_signin, :link_to_signup, to: :helpers

  private
    def cannot_vote_text
      if reason.present? && reason == :not_logged_in
        t("votes.budget_investments.not_logged_in",
          signin: link_to_signin, signup: link_to_signup)
      elsif reason.present? && !voted?
        t("budgets.ballots.reasons_for_not_balloting.#{reason}",
          verify_account: link_to_verify_account,
          my_heading: link_to_my_heading,
          change_ballot: link_to_change_ballot,
          heading_link: heading_link(assigned_heading, budget))
      end
    end
end
