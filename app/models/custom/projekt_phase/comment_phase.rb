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

  def resource_count
    projekt.comments.count
  end

  private

    def phase_specific_permission_problems(user, location)
      nil
    end
end
