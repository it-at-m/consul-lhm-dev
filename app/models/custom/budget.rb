require_dependency Rails.root.join("app", "models", "budget").to_s

class Budget < ApplicationRecord
  belongs_to :projekt, optional: true
  has_one :budget_phase, through: :projekt

  def investments_filters
    [
      ("all" if selecting? || valuating? || publishing_prices? || balloting? || reviewing_ballots?),
      ("winners" if finished?),
      ("selected" if publishing_prices_or_later? && !finished?),
      # ("unselected" if publishing_prices_or_later?),
      ("feasible" if selecting? || valuating?),
      ("unfeasible" if selecting? || valuating_or_later?),
      ("undecided" if selecting? || valuating?)
    ].compact
  end

  def distributed_voting?
    voting_style == "distributed"
  end

  def reason_for_not_allowing_new_proposal(user)
    return :not_logged_in unless user
    return :organization  if user.organization?
    return budget_phase.geozone_permission_problem(user) if budget_phase.geozone_permission_problem(user)

    nil
  end
end
