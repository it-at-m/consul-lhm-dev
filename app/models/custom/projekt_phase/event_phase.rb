class ProjektPhase::EventPhase < ProjektPhase
  def phase_activated?
    active?
  end

  def name
    "event_phase"
  end

  def resources_name
    "projekt_events"
  end
end
