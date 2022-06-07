class ProjektPhase::LegislationProcessPhase < ProjektPhase
  def phase_activated?
    active?
  end

  def phase_info_activated?
    info_active?
  end

  def name
    'legislation_process_phase'
  end

  def resources_name
    'legislation_processes'
  end

  def default_order
    3
  end
end
