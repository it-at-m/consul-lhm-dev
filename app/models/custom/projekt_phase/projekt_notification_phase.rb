class ProjektPhase::ProjektNotificationPhase < ProjektPhase
  has_many :projekt_notifications, foreign_key: :projekt_phase_id,
    dependent: :destroy, inverse_of: :projekt_phase

  def phase_activated?
    active?
  end

  def name
    "projekt_notification_phase"
  end

  def resources_name
    "projekt_notifications"
  end

  def resource_count
    projekt_notifications.count
  end

  def admin_nav_bar_items
    %w[naming].push(resources_name)
  end

  def safe_to_destroy?
    projekt_notifications.empty?
  end

  private

    def phase_specific_permission_problems(user, location)
      return :organization if user.organization?
    end
end
