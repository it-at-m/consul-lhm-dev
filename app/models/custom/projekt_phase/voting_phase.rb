class ProjektPhase::VotingPhase < ProjektPhase
  def phase_activated?
    active?
  end

  def name
    "voting_phase"
  end

  def resources_name
    "polls"
  end

  def default_order
    4
  end

  def resource_count
    projekt_tree_ids = projekt.all_children_ids.unshift(projekt.id)
    Poll.base_selection
      .where(projekt_id: (Poll.scoped_projekt_ids_for_footer(projekt) & projekt_tree_ids))
      .count
  end

  private

    def phase_specific_permission_problems(user, location)
      return :organization if user.organization?
    end
end
