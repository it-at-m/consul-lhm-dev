class ProjektPhase::NewsfeedPhase < ProjektPhase
  def phase_activated?
    ProjektSetting.find_by(projekt: projekt, key: "projekt_feature.phase.newsfeed").value.present?
  end

  def phase_info_activated?
    ProjektSetting.find_by(projekt: projekt, key: "projekt_feature.phase.newsfeed_info").value.present?
  end

  def name
    'newsfeed_phase'
  end

  def resources_name
    'newsfeed'
  end
end
