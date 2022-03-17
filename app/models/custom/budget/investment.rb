require_dependency Rails.root.join("app", "models", "budget", "investment").to_s

class Budget
  class Investment < ApplicationRecord
    delegate :projekt, to: :budget

    scope :seen, -> { where.not(ignored_flag_at: nil) }
    scope :unseen, -> { where(ignored_flag_at: nil) }
  end
end
