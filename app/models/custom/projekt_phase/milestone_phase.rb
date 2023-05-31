class ProjektPhase::MilestonePhase < ProjektPhase
  def phase_activated?
    active?
  end

  def name
    "milestone_phase"
  end

  def resources_name
    "milestones"
  end

  def default_order
    5
  end

  def resource_count
    projekt.milestones.count
  end

  private

    def phase_specific_permission_problems(user, location)
      return :organization if user.organization?
    end
end
