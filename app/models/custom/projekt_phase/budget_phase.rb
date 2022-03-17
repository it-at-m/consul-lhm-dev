class ProjektPhase::BudgetPhase < ProjektPhase
  def phase_activated?
    projekt.budget.present?
  end

  def phase_info_activated?
    ProjektSetting.find_by(projekt: projekt, key: "projekt_feature.phase.budget_info").value.present? &&
      projekt.budget.present?
  end

  def name
    'budget_phase'
  end

  def resources_name
    'budget'
  end
end
