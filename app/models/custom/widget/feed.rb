require_dependency Rails.root.join("app", "models", "widget", "feed").to_s

class Widget::Feed < ApplicationRecord
  def polls
    Poll.current.order(created_at: :asc).limit(limit)
  end

  def proposals
    Proposal.published.not_archived.sort_by_created_at.limit(limit)
  end

  def debates
    Debate.sort_by_created_at.limit(limit)
  end
end
