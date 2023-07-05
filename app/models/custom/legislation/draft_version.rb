require_dependency Rails.root.join("app", "models", "legislation", "draft_version").to_s

class Legislation::DraftVersion < ApplicationRecord
  delegate :projekt_phase, to: :process
  alias_attribute :legislation_phase, :projekt_phase

  def permission_problem(user)
    @permission_problem = legislation_phase.permission_problem(user)
  end

  def comments_allowed?(user)
    permission_problem(user).nil?
  end
end
