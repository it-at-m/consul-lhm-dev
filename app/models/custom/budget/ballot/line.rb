require_dependency Rails.root.join("app", "models", "budget", "ballot", "line").to_s

class Budget
  class Ballot
    class Line < ApplicationRecord
      after_create :update_qualified_total_ballot_line_weight
      after_destroy :update_qualified_total_ballot_line_weight

      private

        def update_qualified_total_ballot_line_weight
          new_qualified_total_ballot_line_weight = investment.budget_ballot_lines
                                                             .sum(:line_weight)

          investment.update!(qualified_total_ballot_line_weight: new_qualified_total_ballot_line_weight)
        end
    end
  end
end
