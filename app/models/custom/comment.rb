require_dependency Rails.root.join("app", "models", "comment").to_s

class Comment < ApplicationRecord
  scope :seen, -> { where.not(ignored_flag_at: nil) }
  scope :unseen, -> { where(ignored_flag_at: nil) }

  # scope :moderatable_by_projekt_manager, -> (projekt_manager_id) {
  #   joins("LEFT JOIN projekts ON comments.commentable_id = projekts.id AND comments.commentable_type = 'Projekt'").

  #   joins("LEFT JOIN debates ON comments.commentable_id = debates.id AND comments.commentable_type = 'Debate' ").
  #   joins("LEFT JOIN projekts AS debates_projekts ON debates.projekt_id = debates_projekts.id" ).

  #   joins("LEFT JOIN proposals ON comments.commentable_id = proposals.id AND comments.commentable_type = 'Proposal' ").
  #   joins("LEFT JOIN projekts AS proposals_projekts ON proposals.projekt_id = proposals_projekts.id" ).

  #   joins("LEFT JOIN polls ON comments.commentable_id = polls.id AND comments.commentable_type = 'Poll' ").
  #   joins("LEFT JOIN projekts AS polls_projekts ON polls.projekt_id = polls_projekts.id" ).

  #   # budget_investments

  #   where("projekts.projekt_manager_id = ? OR "\
  #         "debates_projekts.projekt_manager_id = ? OR "\
  #         "proposals_projekts.projekt_manager_id = ? OR "\
  #         "polls_projekts.projekt_manager_id = ?",
  #          projekt_manager_id,
  #          projekt_manager_id,
  #          projekt_manager_id,
  #          projekt_manager_id
  #   )
  # }

  def projekt
    return commentable if commentable.is_a?(Projekt)

    commentable.projekt if commentable.projekt.present?
  end

  def votable_by?(user)
    user.present?
  end
end
