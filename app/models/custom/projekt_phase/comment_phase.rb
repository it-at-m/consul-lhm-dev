class ProjektPhase::CommentPhase < ProjektPhase
  def phase_activated?
    active?
  end

  def name
    "comment_phase"
  end

  def resources_name
    "comments"
  end

  def default_order
    1
  end

  private

    def phase_specific_permission_problems(user, location)
      nil
    end
end
