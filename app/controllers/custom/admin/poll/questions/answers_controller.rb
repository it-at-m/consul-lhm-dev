require_dependency Rails.root.join("app", "controllers", "admin", "poll", "questions", "answers_controller").to_s

class Admin::Poll::Questions::AnswersController < Admin::Poll::BaseController
  def new
    @answer = ::Poll::Question::Answer.new
    @question = ::Poll::Question.find_by(id: params[:question_id])
  end

  def edit
    @question = @answer.question
  end

  def destroy
    load_answer
    if @answer.question.poll.safe_to_delete_answer?
      @answer.destroy!
      redirect_to admin_question_path(@answer.question), notice: t("custom.admin.polls.questions.answers.notice.delete.success")
    else
      redirect_to admin_question_path(@answer.question), flash: { error: t("custom.admin.polls.questions.answers.notice.delete.error") }
    end
  end

  private

    def answer_params
      attributes = [
        :title, :description, :given_order, :question_id, :open_answer, :more_info_link,
        :next_question_id, documents_attributes: document_attributes]

      params.require(:poll_question_answer).permit(
        *attributes, translation_params(Poll::Question::Answer)
      )
    end
end
