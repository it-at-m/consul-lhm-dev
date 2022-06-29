class ProjektPhase::ProposalPhase < ProjektPhase
  def phase_activated?
    active?
  end

  def name
    'proposal_phase'
  end

  def resources_name
    'proposals'
  end

  def default_order
    4
  end
end
