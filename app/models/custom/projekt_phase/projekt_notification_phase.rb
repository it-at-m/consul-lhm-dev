class ProjektPhase::ProjektNotificationPhase < ProjektPhase
  def phase_activated?
    active?
  end

  def name
    "projekt_notification_phase"
  end

  def resources_name
    "projekt_notifications"
  end
end
