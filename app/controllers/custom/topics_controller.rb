require_dependency Rails.root.join("app", "controllers", "topics_controller").to_s

class TopicsController < ApplicationController
  def show
    @commentable = @topic
    @comment_tree = CommentTree.new(@commentable, params[:page], @current_order)
    set_comment_flags(@comment_tree.comments)

    if Setting.new_design_enabled?
      render :show_new
    else
      render :show
    end
  end
end
