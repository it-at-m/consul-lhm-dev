require_dependency Rails.root.join("app", "models", "legislation", "draft_version").to_s

class Legislation::DraftVersion < ApplicationRecord
  delegate :projekt_phase, to: :process
  alias_attribute :legislation_phase, :projekt_phase

  def self.model_name
    mname = super
    mname.instance_variable_set(:@route_key, "draft_versions")
    mname.instance_variable_set(:@singular_route_key, "draft_version")
    mname
  end

  def permission_problem(user)
    @permission_problem = legislation_phase.permission_problem(user)
  end

  def comments_allowed?(user)
    permission_problem(user).nil?
  end
end
