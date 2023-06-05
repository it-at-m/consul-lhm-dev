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

  def resource_count
    projekt.questions.count
  end

  private

    def phase_specific_permission_problems(user, location)
      return :organization if user.organization?
    end
end
