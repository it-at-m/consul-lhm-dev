class ProjektPhase::DebatePhase < ProjektPhase
  def phase_activated?
    active?
  end

  def name
    'debate_phase'
  end

  def resources_name
    'debates'
  end

  def default_order
    2
  end
end
