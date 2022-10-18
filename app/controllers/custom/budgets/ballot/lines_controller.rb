require_dependency Rails.root.join("app", "controllers", "budgets", "ballot", "lines_controller").to_s

module Budgets
  module Ballot
    class LinesController < ApplicationController
      before_action :set_variables_for_sidebar_filter, only: %i[create destroy]

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
    end
  end
end
