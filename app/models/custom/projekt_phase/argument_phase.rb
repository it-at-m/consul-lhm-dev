class ProjektPhase::ArgumentPhase < ProjektPhase
  def phase_activated?
    # projekt.questions.any?
    active?
  end

  def name
    "argument_phase"
  end

  def resources_name
    "projekt_arguments"
  end

  def default_order
    4
  end
end
