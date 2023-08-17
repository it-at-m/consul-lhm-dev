class FormularAnswersController < ApplicationController
  skip_authorization_check

  def create
    @formular_answer = FormularAnswer.new(formular_answer_params)
    @formular_answer.save!

    redirect_to page_path(@formular_answer.formular.projekt_phase.projekt.page.slug)
  end

  private

    def formular_answer_params
      params.require(:formular_answer).permit(:formular_id, answers: {})
    end
end
