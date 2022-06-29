class ProjektPhase::CommentPhase < ProjektPhase
  def phase_activated?
    active?
  end

  def name
    'comment_phase'
  end

  def resources_name
    'comments'
  end

  def default_order
    1
  end
end
