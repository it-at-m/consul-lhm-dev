require_dependency Rails.root.join("app", "controllers", "comments_controller").to_s

class CommentsController < ApplicationController
  before_action :verify_user_can_comment, only: [:create, :vote]

  def vote
    @comment.vote_by(voter: current_user, vote: params[:value])
    @commentable = @comment.commentable
    respond_with(@comment, @commentable)
  end

  private

  def verify_user_can_comment
    commentable = @comment.commentable

    if current_user && !commentable.comments_allowed?(current_user)
      redirect_to polymorphic_path(commentable), alert: t("comments.comments_closed")
    end
  end
end
