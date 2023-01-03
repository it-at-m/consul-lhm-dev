require_dependency Rails.root.join("app", "components", "budgets", "investments", "ballot_component").to_s

class Budgets::Investments::BallotComponent < ApplicationComponent
  delegate :link_to_signin, :link_to_signup, :link_to_verify_account, to: :helpers

  def initialize(investment:, investment_ids:, ballot:,
                 top_level_active_projekts:, top_level_archived_projekts:)
    @investment = investment
    @investment_ids = investment_ids
    @ballot = ballot
    @top_level_active_projekts = top_level_active_projekts
    @top_level_archived_projekts = top_level_archived_projekts
  end

  private

    def user
      if current_user&.administrator? &&
          controller_name == "offline_ballots" &&
          params[:user_id]
        User.find(params[:user_id])
      else
        current_user
      end
    end

    def reason
      @reason ||= investment.reason_for_not_being_ballotable_by(user, ballot)
    end

    def line_weight_options_for_select
      raise :budget_not_distributed unless budget.distributed_voting?

      remaining_votes = ballot.amount_available(investment.heading)

      return 0 if remaining_votes < 1

      (1..remaining_votes).map { |i| [i, i] }
    end

    def cannot_vote_text
      return nil if voted? &&
        @investment.permission_problem_keys_allowing_ballot_line_deletion.include?(reason)

      if reason == :not_logged_in
        t(path_to_key,
          sign_in: link_to_signin, sign_up: link_to_signup)
      elsif reason.present?
        t(path_to_key,
          verify: link_to_verify_account,
          city: Setting["org_name"],
          geozones: @investment.budget.budget_phase.geozone_restrictions_formatted,
          age_restriction: @investment.budget.budget_phase.age_restriction_formatted)
      end
    end

    def path_to_key
      "custom.projekt_phases.permission_problem.ballot_component.budget_phase.#{reason}"
    end
end
