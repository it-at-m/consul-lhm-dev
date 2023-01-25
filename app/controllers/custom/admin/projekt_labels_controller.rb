class Admin::ProjektLabelsController < Admin::BaseController
  include Translatable
  respond_to :js

  before_action :set_projekt
  load_and_authorize_resource only: %i[edit update destroy]

  def new
    @projekt_label = ProjektLabel.new
    authorize! :create, @projekt_label

    render "custom/admin/projekts/edit/projekt_labels/new"
  end

  def create
    @projekt_label = ProjektLabel.new(projekt_label_params)
    @projekt_label.projekt = @projekt
    authorize! :create, @projekt_label

    if @projekt_label.save
      redirect_to edit_admin_projekt_path(@projekt, anchor: "tab-projekt-labels")
    else
      render :new
    end
  end

  def edit
    render "custom/admin/projekts/edit/projekt_labels/edit"
  end

  def update
    if @projekt_label.update(projekt_label_params)
      redirect_to edit_admin_projekt_path(@projekt, anchor: "tab-projekt-labels")
    else
      render :edit
    end
  end

  def destroy
    @projekt_label.destroy!
    redirect_to edit_admin_projekt_path(@projekt, anchor: "tab-projekt-labels"),
                notice: t("custom.admin.projekt.label.destroy.success")
  end

  private

    def set_projekt
      @projekt = Projekt.find(params[:projekt_id])
    end

    def projekt_label_params
      params.require(:projekt_label).permit(:color, :icon, :projekt_id, translation_params(ProjektLabel))
    end
end
