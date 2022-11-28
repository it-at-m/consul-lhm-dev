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

  private

    def phase_specific_permission_problems(user, location)
      return :organization if user.organization?
    end
end
