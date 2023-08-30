class FormularAnswersController < ApplicationController
  skip_authorization_check
  respond_to :js

  invisible_captcha only: [:create], honeypot: :subtitle

  def create
    @formular_answer = FormularAnswer.new(formular_answer_params)
    @formular_answer.answer_errors = {}
    authenticate_user! if @formular_answer.formular.requires_login?

    @formular_fields = @formular_answer.formular.formular_fields.primary.each(&:set_custom_attributes)
    validate_answer(@formular_answer)

    if @formular_answer.answer_errors.none? && @formular_answer.save
      email = @formular_answer.email_address
      Mailer.formular_answer_confirmation(email).deliver_later if email.present?
      @success_notification = t("custom.formular_answer.notifications.success")
    end

    render :create
  end

  def update
    @formular_answer = FormularAnswer.find(params[:id])
    @formular_answer.answer_errors = {}
    authenticate_user! if @formular_answer.formular.requires_login?

    @formular_answer.answers = @formular_answer.answers.merge(formular_answer_params["answers"].to_h)

    @formular_fields = @formular_answer.formular.formular_fields.follow_up.each(&:set_custom_attributes)
    validate_answer(@formular_answer)

    if @formular_answer.answer_errors.none? && @formular_answer.save
      @success_notification = t("custom.formular_answer.notifications.success")
    end
  end

  private

    def formular_answer_params
      params.require(:formular_answer).permit(:formular_id, answers: {})
    end

    def validate_answer(formular_answer)
      formular_fields = formular_answer.persisted? ? formular_answer.formular_fields.follow_up : formular_answer.formular_fields.primary

      formular_fields.each do |formular_field|
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
