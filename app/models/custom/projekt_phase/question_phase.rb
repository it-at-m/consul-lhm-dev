class ProjektPhase::QuestionPhase < ProjektPhase
  def phase_activated?
    active?
  end

  def name
    "question_phase"
  end

  def resources_name
    "projekt_questions"
  end

  def default_order
    3
  end

  def participation_open?
    projekt.present? &&
    projekt.question_phase.current?
  end
end
