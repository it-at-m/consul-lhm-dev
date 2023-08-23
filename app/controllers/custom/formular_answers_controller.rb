class FormularAnswersController < ApplicationController
  skip_authorization_check
  respond_to :js

  def create
    @formular_answer = FormularAnswer.new(formular_answer_params)
    @formular_answer.formular.formular_fields.each(&:set_custom_attributes)
    validate_answer(@formular_answer)

    if @formular_answer.answer_errors.none? && @formular_answer.save
      email_key = @formular_answer.formular.formular_fields
        .where(kind: "email").where("options ->> 'email_for_confirmation' = ?", "1").first.key
      email = @formular_answer.answers[email_key]
      Mailer.formular_answer_confirmation(email).deliver_later
      @success_notification = t("custom.formular_answer.notifications.success")
    end

    render :create
  end

  private

    def formular_answer_params
      params.require(:formular_answer).permit(:formular_id, answers: {})
    end

    def validate_answer(formular_answer)
      formular_answer.formular_fields.each do |formular_field|
        validate_for_presence(formular_answer, formular_field) if formular_field.required?
        next if formular_answer.answer_errors[formular_field.key].present?

        next if formular_answer.answers[formular_field.key].blank?

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
