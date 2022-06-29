class ProjektPhase::NewsfeedPhase < ProjektPhase
  def phase_activated?
    active?
  end

  def name
    'newsfeed_phase'
  end

  def resources_name
    'newsfeed'
  end
end
