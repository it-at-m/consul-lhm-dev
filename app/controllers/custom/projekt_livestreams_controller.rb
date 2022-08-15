class ProjektLivestreamsController < ApplicationController
  skip_authorization_check
  respond_to :js

  layout false

  def show
    @current_projekt_livestream = ProjektLivestream.find(params[:id])
    @other_livestreams = @current_projekt_livestream.projekt.projekt_livestreams.select(:id, :title)

    first_projekt_question = @current_projekt_livestream.projekt_questions.first

    if first_projekt_question.present?
      @commentable = first_projekt_question
      @comment_tree = CommentTree.new(@commentable, params[:page], "oldest")
      set_comment_flags(@comment_tree.comments)
    end
  end
end
