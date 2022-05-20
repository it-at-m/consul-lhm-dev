require_dependency Rails.root.join("app", "models", "widget", "feed").to_s

class Widget::Feed < ApplicationRecord
  KINDS = %w[polls proposals debates].freeze

  def polls
    Poll.current.where(show_on_home_page: true).order(created_at: :asc).limit(limit)
  end

  def proposals
    Proposal.published.not_archived.with_current_projekt.sort_by_created_at.limit(limit)
  end

  def debates
    Debate.with_current_projekt.sort_by_created_at.limit(limit)
  end
end
