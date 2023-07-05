class ProjektPhase::LegislationPhase < ProjektPhase
  has_one :legislation_process, foreign_key: :projekt_phase_id, class_name: "Legislation::Process",
    dependent: :restrict_with_exception, inverse_of: :projekt_phase

  def phase_activated?
    active?
  end

  def name
    "legislation_phase"
  end

  def resources_name
    "legislation"
  end

  def default_order
    3
  end

  def admin_nav_bar_items
    %w[duration naming restrictions]
  end

  def safe_to_destroy?
    legislation_processes.empty?
  end

  private

    def phase_specific_permission_problems(user, location)
      return :organization if user.organization?
    end
end
