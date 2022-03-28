class ProjektPhase::ProjektNotificationPhase < ProjektPhase
  def phase_activated?
    ProjektSetting.find_by(projekt: projekt, key: "projekt_feature.phase.projekt_notification").value.present?
  end

  def phase_info_activated?
    ProjektSetting.find_by(projekt: projekt, key: "projekt_feature.phase.projekt_notification_info").value.present?
  end

  def name
    'projekt_notification_phase'
  end

  def resources_name
    'projekt_notifications'
  end
end
