require_dependency Rails.root.join("app", "models", "milestone").to_s

class Milestone < ApplicationRecord
  def self.order_by_publication_date(order = :asc)
    order(publication_date: order, created_at: :asc)
  end
end
