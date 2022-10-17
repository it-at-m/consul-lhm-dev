require_dependency Rails.root.join("app", "components", "budgets", "investments", "ballot_component").to_s

class Budgets::Investments::BallotComponent < ApplicationComponent
  delegate :link_to_signin, :link_to_signup, to: :helpers

  def initialize(investment:, investment_ids:, ballot:,
                 top_level_active_projekts:, top_level_archived_projekts:)
    @investment = investment
    @investment_ids = investment_ids
    @ballot = ballot
    @top_level_active_projekts = top_level_active_projekts
    @top_level_archived_projekts = top_level_archived_projekts
  end

  private

    def line_weight_options_for_select
      raise :budget_not_distributed unless budget.distributed_voting?

      remaining_votes = ballot.amount_available(investment.heading)

      return 0 if remaining_votes < 1

      (1..remaining_votes).map { |i| [i, i] }
    end

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
