class ProjektPhase::LegislationPhase < ProjektPhase
  def phase_activated?
    active?
  end

  def name
    "legislation_phase"
  end

  def resources_name
    "legislation"
  end

  def default_order
    3
  end
end
