class ProjektPhase::EventPhase < ProjektPhase
  def phase_activated?
    ProjektSetting.find_by(projekt: projekt, key: "projekt_feature.phase.event").value.present?
  end

  def phase_info_activated?
    ProjektSetting.find_by(projekt: projekt, key: "projekt_feature.phase.event_info").value.present?
  end

  def name
    'event_phase'
  end

  def resources_name
    'projekt_events'
  end
end
