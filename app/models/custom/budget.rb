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

  def show_percentage_values_only?
    budget_phase.projekt_settings
      .find_by(key: "projekt_feature.budgets.show_relative_ballotting_results")
      .value
      .present?
  end

  def projekt_phase
    budget_phase
  end
end
