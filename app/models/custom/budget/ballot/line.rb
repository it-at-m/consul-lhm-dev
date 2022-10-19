require_dependency Rails.root.join("app", "models", "budget", "ballot", "line").to_s

class Budget
  class Ballot
    class Line < ApplicationRecord
      after_create :update_qualified_votes_count
      after_destroy :update_qualified_votes_count

      private

        def update_qualified_votes_count
          if ballot.user.level_three_verified?
            line_weight ||= 1

            if persisted?
              investment.increment!(:qualified_votes_count, line_weight)
            else
              investment.decrement!(:qualified_votes_count, line_weight)
            end
          end
        end
    end
  end
end
