class ProjektPhase::VotingPhase < ProjektPhase
  has_many :polls, foreign_key: :projekt_phase_id,
    dependent: :restrict_with_exception, inverse_of: :projekt_phase

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

  def admin_nav_bar_items
    %w[duration naming restrictions settings]
  end

  def safe_to_destroy?
    polls.empty?
  end

  private

    def phase_specific_permission_problems(user, location)
      return :organization if user.organization?
    end
end
