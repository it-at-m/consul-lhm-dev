require_dependency Rails.root.join("app", "models", "comment").to_s

class Comment < ApplicationRecord
  scope :seen, -> { where.not(ignored_flag_at: nil) }
  scope :unseen, -> { where(ignored_flag_at: nil) }

  delegate :comments_allowed?, to: :projekt, allow_nil: true

  def self.moderatable_by_projekt_manager(projekt_manager_id)
    managed_projekt_ids = ProjektManager.find(projekt_manager_id).projekt_ids

    Comment.joins("LEFT JOIN projekts ON comments.commentable_id = projekts.id AND comments.commentable_type = 'Projekt'").

      joins("LEFT JOIN debates ON comments.commentable_id = debates.id AND comments.commentable_type = 'Debate' ").
      joins("LEFT JOIN projekts AS debates_projekts ON debates.projekt_id = debates_projekts.id").

      joins("LEFT JOIN proposals ON comments.commentable_id = proposals.id AND comments.commentable_type = 'Proposal' ").
      joins("LEFT JOIN projekts AS proposals_projekts ON proposals.projekt_id = proposals_projekts.id" ).

      joins("LEFT JOIN polls ON comments.commentable_id = polls.id AND comments.commentable_type = 'Poll' ").
      joins("LEFT JOIN projekts AS polls_projekts ON polls.projekt_id = polls_projekts.id" ).

      joins("LEFT JOIN budget_investments ON comments.commentable_id = budget_investments.id AND comments.commentable_type = 'Budget::Investment' ").
      joins("LEFT JOIN budgets AS budget_investments_budgets ON budget_investments.budget_id = budget_investments_budgets.id" ).
      joins("LEFT JOIN projekts AS budgets_projekts ON budget_investments_budgets.projekt_id = budgets_projekts.id" ).

      where("projekts.id IN (?) OR "\
             "debates_projekts.id IN (?) OR "\
             "proposals_projekts.id IN (?) OR "\
             "polls_projekts.id IN (?) OR "\
             "budgets_projekts.id IN (?)",
             managed_projekt_ids,
             managed_projekt_ids,
             managed_projekt_ids,
             managed_projekt_ids,
             managed_projekt_ids
      )
  end

  def next_comments
    self.class
      .where(commentable_id: commentable_id, commentable_type: commentable_type)
      .where("id > ?", id)
  end

  def projekt
    return commentable if commentable.is_a?(Projekt)

    commentable&.projekt.presence if commentable.respond_to?(:projekt)
  end
end
