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

  def resource_count
    projekt.projekt_arguments.count
  end

  private

    def phase_specific_permission_problems(user, location)
      return :organization if user.organization?
    end
end
