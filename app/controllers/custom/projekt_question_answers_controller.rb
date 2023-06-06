class ProjektQuestionAnswersController < ApplicationController
  before_action :authenticate_user!

  skip_authorization_check
  has_orders %w[most_voted newest oldest]

  before_action :set_projekt, only: [:create, :update]
  # load_and_authorize_resource :projekt
  # load_and_authorize_resource :projekt_question, through: :projekt

  respond_to :html, :js

  def create
    question_option = ProjektQuestionOption.find(params[:projekt_question_answer][:projekt_question_option_id])
    @question = question_option.question
    question_phase = @question.projekt_phase

    if !question_phase.phase_activated? && @question.root_question?
      render text: "Question phase not active", status: :unprocessable_entity
    else
      @answer = ProjektQuestionAnswer.find_or_initialize_by(
        user: current_user,
        question: @question
      )

      @answer.assign_attributes(
        question_option: question_option,
      )

      @answer.save!
      @commentable = @question

      @comment_tree = CommentTree.new(@commentable, params[:page], @current_order)
      set_comment_flags(@comment_tree.comments)

      render "custom/projekt_questions/show.js.erb", format: :js
    end
  end

  def update
    question_option = ProjektQuestionOption.find(params[:projekt_question_answer][:projekt_question_option_id])
    @question = question_option.question

    if question_option.nil?
      head :not_found and return
    end

    if @question.permission_problem(current_user).present?
      head :forbidden
    else
      @answer = ProjektQuestionAnswer.find(params[:id])
      @answer.update(question_option: question_option)

      @answer.save!
      @commentable = @question

      @comment_tree = CommentTree.new(@commentable, params[:page], @current_order)
      set_comment_flags(@comment_tree.comments)

      render "custom/projekt_questions/show.js.erb"
    end
  end

  private

  def set_projekt
    @projekt = Projekt.find(params[:projekt_id])
  end

  # def answer_params
  #   params.require(:projekt_question_answer).permit(:projekt_question_option_id)
  # end
end
