class ProjektQuestionsController < ApplicationController
  before_action :set_question, only: [:show]

  skip_authorization_check

  # load_and_authorize_resource :projekt
  # load_and_authorize_resource :question, through: :projekt

  has_orders %w[most_voted newest oldest], only: :show

  respond_to :html, :js

  layout false

  def index
    @projekt = Projekt.find(params[:projekt_id])

    @projekt_questions =
      if params[:current_projekt_question_id].present?
        current_projekt_question = ProjektQuestion.find(params[:current_projekt_question_id])

        if current_projekt_question.present?
          current_projekt_question.sibling_questions
        else
          head :not_found
        end
      else
        @projekt.questions
      end
  end

  def show
    @commentable = @question
    @current_order = "newest"

    @comment_tree = CommentTree.new(@commentable, params[:page], @current_order)
    set_comment_flags(@comment_tree.comments)

    @answer = @question.answer_for_user(current_user) || ProjektQuestionAnswer.new

    if @question.livestream_question?
      @projekt_livestream_livequestion_path = new_questions_projekt_livestream_path(@question.projekt_livestream.id, current_projekt_question_id: @question.id, most_recent_question_id: @question.most_recent_question_id)
    end
  end

  private

    def set_question
      @question = ProjektQuestion.find(params[:id])
    end
end
