class ProjektLivestreamsController < ApplicationController
  skip_authorization_check
  respond_to :js

  before_action :set_projekt_livestream, only: [:show, :new_questions]

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

  def new_questions
    @new_questions =
      if params[:last_question_id]
        last_projekt_question = ProjektQuestion.find(params[:last_question_id])

        last_projekt_question.next_questions
      else
        @current_projekt_livestream.projekt_questions
      end
  end

  def set_projekt_livestream
    @current_projekt_livestream = ProjektLivestream.find(params[:id])
  end
end
