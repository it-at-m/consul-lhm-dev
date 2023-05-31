class ProjektPhase::LivestreamPhase < ProjektPhase
  def phase_activated?
    active?
  end

  def name
    "livestream_phase"
  end

  def resources_name
    "projekt_livestreams"
  end

  def default_order
    2
  end

  def resource_count
    projekt.projekt_livestreams.count
  end

  private

    def phase_specific_permission_problems(user, location)
      return :organization if user.organization?
    end
end
