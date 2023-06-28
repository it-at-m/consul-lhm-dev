class Admin::ProjektLabelsController < Admin::BaseController
  include Translatable
  respond_to :js

  before_action :set_projekt_phase
  load_and_authorize_resource only: %i[edit update destroy]

  def new
    @projekt_label = ProjektLabel.new
    authorize! :create, @projekt_label
  end

  def create
    @projekt_label = ProjektLabel.new(projekt_label_params)
    @projekt_label.projekt_phase = @projekt_phase
    authorize! :create, @projekt_label

    if @projekt_label.save
      redirect_to projekt_labels_admin_projekt_phase_path(@projekt_phase)
    else
      render :new
    end
  end

  def edit
    render "custom/admin/projekt_labels/edit"
  end

  def update
    if @projekt_label.update(projekt_label_params)
      redirect_to projekt_labels_admin_projekt_phase_path(@projekt_phase)
    else
      render :edit
    end
  end

  def destroy
    @projekt_label.destroy!
    redirect_to projekt_labels_admin_projekt_phase_path(@projekt_phase),
                notice: t("custom.admin.projekt.label.destroy.success")
  end

  private

    def set_projekt_phase
      @projekt_phase = ProjektPhase.find(params[:projekt_phase_id])
    end

    def projekt_label_params
      params.require(:projekt_label).permit(:color, :icon, :projekt_id, translation_params(ProjektLabel))
    end
end
