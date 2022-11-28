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

  private

    def phase_specific_permission_problems(user, location)
      return :organization if user.organization?
    end
end
