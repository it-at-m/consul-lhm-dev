require_dependency Rails.root.join("app", "controllers", "budgets", "ballot", "lines_controller").to_s

module Budgets
  module Ballot
    class LinesController < ApplicationController
      def create
        load_investment
        load_heading
        load_map
        set_filters

        if permission_problem.present?
          return
        end

        @ballot.add_investment(@investment, params[:line_weight])
      end

      def destroy
        @investment = @line.investment
        load_heading
        load_map
        set_filters

        if permission_problem.present? &&
            !@investment.permission_problem_keys_allowing_ballot_line_deletion.include?(permission_problem)
          return
        end

        @line.destroy!
        load_investments
      end

      private

        def load_ballot
          user = User.find_by(id: params[:user_id]) || current_user
          @ballot = Budget::Ballot.where(user: user, budget: @budget).first_or_create!
        end

        def permission_problem
          @permission_problem = @investment.reason_for_not_being_ballotable_by(current_user, @line.ballot)
        end

        def set_filters
          @valid_filters = @budget.investments_filters
          params[:filter] ||= "all" if @budget.phase.in?(["publishing_prices", "balloting", "reviewing_ballots"])
          @current_filter = @valid_filters.include?(params[:filter]) ? params[:filter] : nil
        end
    end
  end
end
