class ProjektQuestionAnswersController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_resident!

  skip_authorization_check
  has_orders %w[most_voted newest oldest]

  before_action :set_projekt, only: [:create, :update]
  # load_and_authorize_resource :projekt
  # load_and_authorize_resource :projekt_question, through: :projekt

  respond_to :html, :js

  def create
    if @projekt.question_phase.active?
      question_option = ProjektQuestionOption.find(params[:projekt_question_answer][:projekt_question_option_id])
      @question = question_option.question

      @answer = ProjektQuestionAnswer.new(
        user: current_user,
        question_option: question_option,
        question: @question,
        **answer_params
      )
      @answer.save!
      @commentable = @question
      @comment_tree = CommentTree.new(@commentable, params[:page], @current_order)
      set_comment_flags(@comment_tree.comments)

      render 'custom/projekt_questions/show.js.erb', format: :js
    end
  end

  def update
    if @projekt.question_phase.active?
      question_option = ProjektQuestionOption.find(params[:projekt_question_answer][:projekt_question_option_id])
      @question = question_option.question

      @answer = ProjektQuestionAnswer.find(params[:id])
      @answer.update(question_option: question_option)

      @answer.save!
      @commentable = @question
      @comment_tree = CommentTree.new(@commentable, params[:page], @current_order)
      set_comment_flags(@comment_tree.comments)

      render 'custom/projekt_questions/show.js.erb', format: :js
    end
  end

  private

  def set_projekt
    @projekt = Projekt.find(params[:projekt_id])
  end

    def answer_params
      params.require(:projekt_question_answer).permit(:projekt_question_option_id)
    end
end
