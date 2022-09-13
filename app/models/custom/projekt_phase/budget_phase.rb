class ProjektPhase::BudgetPhase < ProjektPhase
  def phase_activated?
    # projekt.budget.present?
    active?
  end

  def name
    'budget_phase'
  end

  def resources_name
    'budget'
  end

  def default_order
    5
  end
end
