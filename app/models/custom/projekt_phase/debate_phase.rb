class ProjektPhase::DebatePhase < ProjektPhase
  has_many :debates, foreign_key: :projekt_phase_id,
    dependent: :restrict_with_exception, inverse_of: :projekt_phase

  def phase_activated?
    active?
  end

  def name
    "debate_phase"
  end

  def resources_name
    "debates"
  end

  def default_order
    2
  end

  def hide_projekt_selector?
    projekt_settings
      .find_by(key: "projekt_feature.debates.hide_projekt_selector")
      .value
      .present?
  end

  def resource_count
    debates.for_public_render.count
  end

  def selectable_by_admins_only?
    feature?("general.only_admins_create_debates")
  end

  def admin_nav_bar_items
    %w[duration naming restrictions settings projekt_labels sentiments]
  end

  def safe_to_destroy?
    debates.empty?
  end

  def downvoting_allowed?
    settings
      .find_by(key: "feature.resource.allow_downvoting")
      .value
      .present?
  end

  private

    def phase_specific_permission_problems(user, location)
      nil
    end
end
