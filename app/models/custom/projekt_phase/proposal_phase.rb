class ProjektPhase::ProposalPhase < ProjektPhase
  def phase_activated?
    active?
  end

  def name
    "proposal_phase"
  end

  def resources_name
    "proposals"
  end

  def default_order
    4
  end

  private

    def phase_specific_permission_problems(user, location)
      return :organization if user.organization? && location == :votes_component
    end
end
