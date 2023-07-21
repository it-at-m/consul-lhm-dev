module ProjektArgumentAdminActions
  extend ActiveSupport::Concern
  include ImageAttributes

  included do
    before_action :set_projekt_phase, :set_namespace
    before_action :set_projekt_argument, only: [:edit, :update, :destroy]
  end

  def create
    @projekt_argument = @projekt_phase.projekt_arguments.new(projekt_argument_params)
    authorize!(:create, @projekt_argument) unless current_user.administrator?

    @projekt_argument.save!
    redirect_to polymorphic_path([@namespace, @projekt_phase], action: "projekt_arguments"),
      notice: t("admin.settings.flash.updated")
  end

  def update
    authorize!(:update, @projekt_argument) unless current_user.administrator?

    @projekt_argument.update!(projekt_argument_params)
    redirect_to polymorphic_path([@namespace, @projekt_phase], action: "projekt_arguments"),
      notice: t("admin.settings.flash.updated")
  end

  def destroy
    authorize!(:destroy, @projekt_argument) unless current_user.administrator?

    @projekt_argument.destroy!
    redirect_to polymorphic_path([@namespace, @projekt_phase], action: "projekt_arguments")
  end

  def send_notifications
    authorize!(:send_notifications, @projekt_phase) unless current_user.administrator?

    NotificationServices::ProjektArgumentsNotifier.call(@projekt_phase.id)
    redirect_to polymorphic_path([@namespace, @projekt_phase], action: "projekt_arguments"),
      notice: t("custom.admin.projekts.edit.projekt_arguments_tab.notifications_sent_notice")
  end

  private

    def projekt_argument_params
      params.require(:projekt_argument).permit(:name, :party, :pro, :position,
                                               :note, image_attributes: image_attributes)
    end

    def set_projekt_phase
      @projekt_phase = ProjektPhase.find(params[:projekt_phase_id])
    end

    def set_projekt_argument
      @projekt_argument = @projekt_phase.projekt_arguments.find(params[:id])
    end

    def set_namespace
      @namespace = params[:controller].split("/")[0].to_sym
    end
end
