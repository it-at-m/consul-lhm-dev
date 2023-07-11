require_dependency Rails.root.join("app", "models", "budget").to_s

class Budget < ApplicationRecord
  belongs_to :old_projekt, foreign_key: :projekt_id, class_name: "Projekt", optional: true # TODO: remove column after data migration con1538

  belongs_to :projekt_phase, optional: true
  delegate :projekt, to: :projekt_phase, allow_nil: true

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
    projekt_phase.settings
      .find_by(key: "feature.general.show_relative_ballotting_results")
      .value
      .present?
  end
end
