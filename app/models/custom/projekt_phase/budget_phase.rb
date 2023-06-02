class ProjektPhase::BudgetPhase < ProjektPhase
  has_one :budget, class_name: "Budget", foreign_key: "projekt_phase_id",
    dependent: :destroy, inverse_of: :projekt_phase

  def phase_activated?
    # projekt.budget.present?
    active?
  end

  def name
    "budget_phase"
  end

  def resources_name
    "budget"
  end

  def default_order
    5
  end

  private

    def phase_specific_permission_problems(user, location)
      return :organization if user.organization?
    end
end
