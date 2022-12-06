class ProjektPhase::VotingPhase < ProjektPhase
  def phase_activated?
    active?
  end

  def name
    "voting_phase"
  end

  def resources_name
    "polls"
  end

  def default_order
    4
  end

  private

    def phase_specific_permission_problems(user, location)
      return :organization if user.organization?
    end
end
