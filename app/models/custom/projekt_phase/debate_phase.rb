class ProjektPhase::DebatePhase < ProjektPhase
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
    projekt_tree_ids = projekt.all_children_ids.unshift(projekt.id)
    Debate.where(projekt_id: (Debate.scoped_projekt_ids_for_footer(projekt) & projekt_tree_ids)).count
  end

  def selectable_by_admins_only?
    projekt_settings.
      find_by(projekt_settings: { key: "projekt_feature.debates.only_admins_create_debates" }).
      value.
      present?
  end

  private

    def phase_specific_permission_problems(user, location)
      nil
    end
end
