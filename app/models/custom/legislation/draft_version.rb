require_dependency Rails.root.join("app", "models", "legislation", "draft_version").to_s

class Legislation::DraftVersion < ApplicationRecord
  delegate :projekt, :legislation_phase, to: :process
  alias_attribute :projekt_phase, :legislation_phase

  def permission_problem(user)
    @permission_problem = legislation_phase.permission_problem(user)
  end

  def comments_allowed?(user)
    permission_problem(user).nil?
  end
end
