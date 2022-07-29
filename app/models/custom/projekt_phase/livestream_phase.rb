class ProjektPhase::LivestreamPhase < ProjektPhase
  def phase_activated?
    active?
  end

  def name
    "livestream_phase"
  end

  def default_order
    2
  end

  def resources_name
    "projekt_livestreams"
  end
end
