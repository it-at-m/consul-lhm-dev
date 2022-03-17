class ProjektPhase::VotingPhase < ProjektPhase
  def phase_activated?
    projekt.polls.any? { |poll| poll.current? }
  end

  def phase_info_activated?
    ProjektSetting.find_by(projekt: projekt, key: "projekt_feature.phase.voting_info").value.present?
  end

  def name
    'voting_phase'
  end

  def resources_name
    'polls'
  end
end
