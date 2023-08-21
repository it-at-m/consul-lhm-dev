class FormularAnswersController < ApplicationController
  skip_authorization_check
  respond_to :js

  def create
    @formular_answer = FormularAnswer.new(formular_answer_params)
    validate_answer(@formular_answer)

    if @formular_answer.answer_errors.any?
      render :create
    else
      @formular_answer.save!
      redirect_to page_path(@formular_answer.formular.projekt_phase.projekt.page.slug)
    end
  end

  private

    def formular_answer_params
      params.require(:formular_answer).permit(:formular_id, answers: {})
    end

    def validate_answer(formular_answer)
      formular_answer.formular_fields.each do |formular_field|
        validate_for_presence(formular_answer, formular_field) if formular_field.required?
        next if formular_answer.answer_errors[formular_field.key].present?

        validations = formular_field.options["validates"]
        next unless validations

        validations.keys.each do |validation|
          send("validate_for_#{validation}", formular_answer, formular_field)
        end
      end
    end

    def validate_for_presence(formular_answer, formular_field)
      return unless formular_answer.answers[formular_field.key].blank?

      error_message = t("custom.formular_answer.errors.blank")
      formular_answer.answer_errors[formular_field.key] = error_message
    end

    def validate_for_length(formular_answer, formular_field)
      rule = formular_field.options["validates"]["length"]

      if rule["minimum"] && formular_answer.answers[formular_field.key].length < rule["minimum"]
        error_message = t("custom.formular_answer.errors.length.minimum", minimum: rule["minimum"])
        formular_answer.answer_errors[formular_field.key] = error_message
      elsif rule["maximum"] && formular_answer.answers[formular_field.key].length > rule["maximum"]
        error_message = t("custom.formular_answer.errors.length.maximum", maximum: rule["maximum"])
        formular_answer.answer_errors[formular_field.key] = error_message
      end
    end

    def validate_for_format(formular_answer, formular_field)
      rule = formular_field.options["validates"]["format"]
      regexp = Regexp.new(rule)

      unless regexp.match?(formular_answer.answers[formular_field.key])
        error_message = t("custom.formular_answer.errors.format")
        formular_answer.answer_errors[formular_field.key] = error_message
      end
    end
end
