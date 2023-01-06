require_dependency Rails.root.join("app", "controllers", "budgets", "ballot", "lines_controller").to_s

module Budgets
  module Ballot
    class LinesController < ApplicationController
      before_action :set_variables_for_sidebar_filter, only: %i[create destroy]

      def create
        load_investment
        load_heading
        load_map

        if permission_problem.present?
          return
        end

        @ballot.add_investment(@investment, params[:line_weight])
      end

      def destroy
        @investment = @line.investment
        load_heading
        load_map

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

        def set_variables_for_sidebar_filter
          @top_level_active_projekts = ::Projekt.where(id: params[:top_level_active_projekt_ids]).to_a
          @top_level_archived_projekts = ::Projekt.where(id: params[:top_level_archived_projekt_ids]).to_a
          @scoped_projekt_ids = params[:scoped_projekt_ids]
          @current_tab_phase = @budget.projekt.budget_phase
          @valid_filters = @budget.investments_filters
          params[:current_tab_path] = "budget_phase_footer_tab"
          params[:id] = @budget.projekt.page.slug
        end

        def permission_problem
          @permission_problem = @investment.reason_for_not_being_ballotable_by(current_user, @line.ballot)
        end
    end
  end
end
