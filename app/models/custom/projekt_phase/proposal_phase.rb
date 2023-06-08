class ProjektPhase::ProposalPhase < ProjektPhase
  def phase_activated?
    active?
  end

  def name
    "proposal_phase"
  end

  def resources_name
    "proposals"
  end

  def default_order
    4
  end

  def hide_projekt_selector?
    projekt_settings
      .find_by(key: "projekt_feature.proposals.hide_projekt_selector")
      .value
      .present?
  end

  def resource_count
    projekt_tree_ids = projekt.all_children_ids.unshift(projekt.id)
    Proposal.base_selection.where(projekt_id: (Proposal.scoped_projekt_ids_for_footer(projekt) & projekt_tree_ids)).count
  end

  def selectable_by_admins_only?
    projekt_settings.
        find_by(projekt_settings: { key: "projekt_feature.proposals.only_admins_create_proposals" }).
        value.
        present?
  end

  private

    def phase_specific_permission_problems(user, location)
      return :organization if user.organization? && location == :votes_component
    end
end
