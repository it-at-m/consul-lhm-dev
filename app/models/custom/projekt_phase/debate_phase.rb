class ProjektPhase::DebatePhase < ProjektPhase
  def phase_activated?
    ProjektSetting.find_by(projekt: projekt, key: "projekt_feature.phase.debate").value.present?
  end

  def phase_info_activated?
    ProjektSetting.find_by(projekt: projekt, key: "projekt_feature.phase.debate_info").value.present?
  end

  def name
    'debate_phase'
  end

  def resources_name
    'debates'
  end
end
