require_dependency Rails.root.join("app", "models", "budget", "investment").to_s

class Budget
  class Investment < ApplicationRecord
    delegate :projekt, to: :budget

    has_many :budget_ballot_lines, class_name: "Budget::Ballot::Line"

    scope :seen, -> { where.not(ignored_flag_at: nil) }
    scope :unseen, -> { where(ignored_flag_at: nil) }

    enum implementation_performer: { city: 0, user: 1 }

    scope :sort_by_random, -> { unscope(:order) }
    scope :sort_by_newest, -> { reorder(created_at: :desc) }

    def self.sort_by_ballot_line_weight(budget = nil)
      order(qualified_votes_count: :desc)
    end

    def register_selection(user, vote_weight = 1)
      vote_by(voter: user, vote: "yes", vote_weight: vote_weight) if selectable_by?(user)
    end

    def total_supporters
      votes_for.joins("INNER JOIN users ON voter_id = users.id").count
    end

    def total_votes
      if budget.distributed_voting?
        votes_for.sum(:vote_weight) + physical_votes
      else
        cached_votes_up + physical_votes
      end
    end
  end
end
