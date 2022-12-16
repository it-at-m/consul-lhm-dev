require_dependency Rails.root.join("app", "models", "budget", "result").to_s

class Budget
  class Result
    def investments
      if budget.distributed_voting?
        heading.investments.selected.sort_by_ballot_line_weight(budget)
      else
        heading.investments.selected.sort_by_ballots
      end
    end
  end
end
