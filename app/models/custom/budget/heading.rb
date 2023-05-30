require_dependency Rails.root.join("app", "models", "budget", "heading").to_s

class Budget
  class Heading < ApplicationRecord
    def total_ballot_votes
      investments_with_ballot_lines_ids = investments.joins(:budget_ballot_lines).ids.uniq
      investments_with_ballot_lines = Budget::Investment.where(id: investments_with_ballot_lines_ids)

      investments_with_ballot_lines.sum(:qualified_total_ballot_line_weight)
    end
  end
end
