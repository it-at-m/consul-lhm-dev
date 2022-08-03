require_dependency Rails.root.join("app", "components", "budgets", "investments", "votes_component").to_s

class Budgets::Investments::VotesComponent < ApplicationComponent
  delegate :link_to_signin, :link_to_signup, :projekt_feature?, to: :helpers

  private

    def cannot_vote_text
      if reason == :not_logged_in
        t("votes.budget_investments.not_logged_in",
          signin: link_to_signin, signup: link_to_signup)

      elsif reason.present? && !user_voted_for?
        t("votes.budget_investments.#{reason}",
          count: investment.group.max_votable_headings,
          verify_account: link_to_verify_account,
          supported_headings: (current_user && current_user.headings_voted_within_group(investment.group).map(&:name).sort.to_sentence))
      end
    end
end
