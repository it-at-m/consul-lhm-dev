class ProjektPhase::BudgetPhase < ProjektPhase
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

  def permission_problem(user)
    return :not_logged_in unless user
    return :organization  if user.organization?
    return :budget_phase_not_active if not_current?
    return :budget_phase_expired if expired?
    return geozone_permission_problem(user) if geozone_permission_problem(user)

    nil
  end
end
