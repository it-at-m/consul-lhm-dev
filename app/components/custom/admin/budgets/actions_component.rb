require_dependency Rails.root.join("app", "components", "admin", "budgets", "actions_component").to_s

class Admin::Budgets::ActionsComponent < ApplicationComponent
  private

    def create_budget_poll_path
      balloting_phase = budget.phases.find_by(kind: "balloting")

      admin_polls_path(poll: {
        name:      budget.name,
        budget_id: budget.id,
        starts_at: balloting_phase.starts_at,
        ends_at:   balloting_phase.ends_at,
        projekt_phase_id: budget.projekt_phase.id
      })
    end
end
