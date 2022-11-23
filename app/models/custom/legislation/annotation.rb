require_dependency Rails.root.join("app", "models", "legislation", "annotation").to_s

class Legislation::Annotation < ApplicationRecord
  delegate :projekt, :legislation_phase, to: :draft_version

  def permission_problem(user)
    legislation_phase.permission_problem(user)
  end

  def comments_allowed?(user)
    permission_problem(user).nil?
  end
end
