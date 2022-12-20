require_dependency Rails.root.join("app", "components", "budgets", "ballot", "ballot_component").to_s

class Budgets::Ballot::BallotComponent < ApplicationComponent
  private

    def budget_phase_link
      page_path(budget.projekt.page.slug, selected_phase_id: budget.projekt_phase, anchor: "filter-subnav")
    end
end
