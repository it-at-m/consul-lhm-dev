class ProjektPhase::ProposalPhase < ProjektPhase
  def phase_activated?
    ProjektSetting.find_by(projekt: projekt, key: "projekt_feature.phase.proposal").value.present?
  end

  def phase_info_activated?
    ProjektSetting.find_by(projekt: projekt, key: "projekt_feature.phase.proposal_info").value.present?
  end

  def name
    'proposal_phase'
  end

  def resources_name
    'proposals'
  end
end
