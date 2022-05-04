require_dependency Rails.root.join("app", "models", "budget").to_s

class Budget < ApplicationRecord
  belongs_to :projekt, optional: true
  has_one :budget_phase, through: :projekt

  def investments_filters
    [
      ("winners" if finished?),
      ("selected" if publishing_prices_or_later? && !finished?),
      ("unselected" if publishing_prices_or_later?),
      ("all" if selecting? || valuating?),
      ("feasible" if selecting? || valuating?),
      ("unfeasible" if selecting? || valuating_or_later?),
      ("undecided" if selecting? || valuating?)
    ].compact
  end
end
