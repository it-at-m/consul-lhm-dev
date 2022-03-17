require_dependency Rails.root.join("app", "models", "comment").to_s

class Comment < ApplicationRecord
  scope :seen, -> { where.not(ignored_flag_at: nil) }
  scope :unseen, -> { where(ignored_flag_at: nil) }
end
