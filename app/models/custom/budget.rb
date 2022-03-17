require_dependency Rails.root.join("app", "models", "budget").to_s

class Budget < ApplicationRecord
  belongs_to :projekt, optional: true
  has_one :budget_phase, through: :projekt
end
