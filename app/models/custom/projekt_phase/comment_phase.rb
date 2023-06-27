class ProjektPhase::CommentPhase < ProjektPhase
  has_many :comments, as: :commentable, inverse_of: :commentable, dependent: :destroy

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
    comments.count
  end

  def admin_nav_bar_items
    %w[duration naming restrictions]
  end

  def safe_to_destroy?
    false
  end

  private

    def phase_specific_permission_problems(user, location)
      nil
    end
end
