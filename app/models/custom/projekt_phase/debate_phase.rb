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
    Debate.where(projekt_phase_id: Debate.scoped_projekt_phase_ids_for_footer(self)).count
  end

  private

    def phase_specific_permission_problems(user, location)
      nil
    end
end
