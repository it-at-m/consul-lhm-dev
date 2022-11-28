class ProjektPhase::NewsfeedPhase < ProjektPhase
  def phase_activated?
    active?
  end

  def name
    "newsfeed_phase"
  end

  def resources_name
    "newsfeed"
  end

  private

    def phase_specific_permission_problems(user, location)
      return :organization if user.organization?
    end
end
