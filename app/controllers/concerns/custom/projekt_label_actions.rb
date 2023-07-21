module ProjektLabelActions
  extend ActiveSupport::Concern
  include Translatable

  included do
    respond_to :js

    before_action :set_projekt_phase, :set_namespace
    before_action :set_projekt_label, only: %i[edit update destroy]
  end

  def new
    @projekt_label = @projekt_phase.projekt_labels.new
    authorize!(:new, @projekt_label) unless current_user.administrator?

    render "custom/admin/projekt_labels/new"
  end

  def create
    @projekt_label = ProjektLabel.new(projekt_label_params)
    @projekt_label.projekt_phase = @projekt_phase
    authorize!(:create, @projekt_label) unless current_user.administrator?

    if @projekt_label.save
      redirect_to polymorphic_path([@namespace, @projekt_phase], action: :projekt_labels)
    else
      render :new
    end
  end

  def edit
    authorize!(:edit, @projekt_label) unless current_user.administrator?
    render "custom/admin/projekt_labels/edit"
  end

  def update
    authorize!(:update, @projekt_label) unless current_user.administrator?

    if @projekt_label.update(projekt_label_params)
      redirect_to polymorphic_path([@namespace, @projekt_phase], action: :projekt_labels)
    else
      render :edit
    end
  end

  def destroy
    authorize!(:destroy, @projekt_label) unless current_user.administrator?

    @projekt_label.destroy!
    redirect_to polymorphic_path([@namespace, @projekt_phase], action: :projekt_labels)
  end

  private

    def set_projekt_phase
      @projekt_phase = ProjektPhase.find(params[:projekt_phase_id])
    end

    def set_namespace
      @namespace = params[:controller].split("/").first.to_sym
    end

    def set_projekt_label
      @projekt_label = ProjektLabel.find(params[:id])
    end

    def projekt_label_params
      params.require(:projekt_label).permit(:color, :icon, :projekt_id, translation_params(ProjektLabel))
    end
end
