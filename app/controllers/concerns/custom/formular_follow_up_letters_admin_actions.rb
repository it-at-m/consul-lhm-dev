module FormularFollowUpLettersAdminActions
  extend ActiveSupport::Concern

  included do
    respond_to :js

    before_action :set_projekt_phase, :set_formular
    before_action :set_formular_follow_up_letter, except: %i[create]
  end

  def create
    @formular_follow_up_letter = @formular.formular_follow_up_letters.new
    @formular_follow_up_letter.formular_answer_ids = params[:formular_answer_ids]

    authorize!(:create, @formular_follow_up_letter) unless current_user.administrator?

    @formular_follow_up_letter.save!
    render "custom/admin/formular_follow_up_letters/create"
  end

  def edit
    authorize!(:edit, @formular_follow_up_letter) unless current_user.administrator?
    render "custom/admin/formular_follow_up_letters/edit"
  end

  def update
    authorize!(:update, @formular_follow_up_letter) unless current_user.administrator?

    if @formular_follow_up_letter.update(formular_follow_up_letter_params)
      @formular = @formular_follow_up_letter.formular
      @formular_fields = @formular.formular_fields
      @formular_answers = @formular.formular_answers
      @image_flag = @formular_answers.any? { |fa| fa.formular_answer_images.present? }

      render "custom/admin/formular_follow_up_letters/update"
    else
      render :edit
    end
  end

  def destroy
    authorize!(:destroy, @formular_follow_up_letter) unless current_user.administrator?

    @formular_follow_up_letter.destroy!
    render "custom/admin/formular_follow_up_letters/destroy"
  end

  def send_emails
    authorize!(:send_emails, @formular_follow_up_letter) unless current_user.administrator?
    @formular_follow_up_letter.delay.deliver
    @formular_follow_up_letter.update!(sent_at: Time.zone.now)

    @formular = @formular_follow_up_letter.formular
    @formular_fields = @formular.formular_fields
    @formular_answers = @formular.formular_answers
    @image_flag = @formular_answers.any? { |fa| fa.formular_answer_images.present? }

    render "custom/admin/formular_follow_up_letters/send_emails"
  end

  def preview
    @follow_up_letter = @formular_follow_up_letter
    @projekt_phase = @formular_follow_up_letter.formular.projekt_phase
    @recipient = @formular_follow_up_letter.recipients.last
    authorize!(:preview, @formular_follow_up_letter) unless current_user.administrator?

    render "custom/admin/formular_follow_up_letters/preview"
  end

  def restore_default_view
    authorize!(:restore_default_view, @formular_follow_up_letter) unless current_user.administrator?

    render "custom/admin/formular_follow_up_letters/restore_default_view"
  end

  private

    def set_projekt_phase
      @projekt_phase = ProjektPhase.find(params[:projekt_phase_id])
    end

    def set_formular
      @formular = Formular.find(params[:formular_id])
    end

    def set_formular_follow_up_letter
      @formular_follow_up_letter = FormularFollowUpLetter.find(params[:id])
    end

    def formular_follow_up_letter_params
      params.require(:formular_follow_up_letter).permit(
        :subject, :body, :show_follow_up_button
      )
    end
end
