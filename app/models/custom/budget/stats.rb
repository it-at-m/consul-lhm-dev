require_dependency Rails.root.join("app", "models", "budget", "stats").to_s

class Budget::Stats
  delegate :show_percentage_values_only?, to: :budget

  def phases
    %w[support vote].select { |phase| send("#{phase}_phase_enabled?") }
  end

  def total_votes
    if budget.distributed_voting?
      budget.investments.pluck(:qualified_total_ballot_line_weight).sum
    else
      budget.ballots.pluck(:ballot_lines_count).sum
    end
  end

  private

    def support_phase_enabled?
      budget.phases.find_by(kind: "selecting").enabled?
    end

    def vote_phase_enabled?
      budget.phases.find_by(kind: "balloting").enabled?
    end
end
