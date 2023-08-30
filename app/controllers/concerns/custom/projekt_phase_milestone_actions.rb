module ProjektPhaseMilestoneActions
  extend ActiveSupport::Concern
  include Translatable
  include ImageAttributes
  include DocumentAttributes

  included do
    before_action :load_milestoneable, only: [:new, :create, :edit, :update, :destroy]
    before_action :load_milestone, only: [:edit, :update, :destroy]
    before_action :load_statuses, only: [:index, :new, :create, :edit, :update]
    helper_method :milestoneable_path
  end

  def new
    @milestone = @milestoneable.milestones.new

    authorize! :new, @milestone unless current_user.administrator?
    render "admin/milestones/new"
  end

  def create
    @milestone = @milestoneable.milestones.new(milestone_params)

    authorize! :create, @milestone unless current_user.administrator?

    if @milestone.save
      NotificationServices::NewProjektMilestoneNotifier.call(@milestone.id)
      redirect_to redirect_path, notice: t("admin.milestones.create.notice")
    else
      render "admin/milestones/new"
    end
  end

  def edit
    authorize! :edit, @milestone unless current_user.administrator?
    render "admin/milestones/edit"
  end

  def update
    authorize! :update, @milestone unless current_user.administrator?

    if @milestone.update(milestone_params)
      redirect_to redirect_path, notice: t("admin.milestones.update.notice")
    else
      render "admin/milestones/edit"
    end
  end

  def destroy
    authorize! :destroy, @milestone unless current_user.administrator?
    @milestone.destroy!

    redirect_to redirect_path, notice: t("admin.milestones.delete.notice")
  end

  private

    def milestone_params
      attributes = [:publication_date, :status_id,
                    translation_params(Milestone),
                    image_attributes: image_attributes, documents_attributes: document_attributes]

      params.require(:milestone).permit(*attributes)
    end

    def milestoneable
      ProjektPhase.find(params[:projekt_phase_id])
    end

    def load_milestoneable
      @milestoneable = milestoneable
    end

    def load_milestone
      @milestone = @milestoneable.milestones.find(params[:id])
    end

    def load_statuses
      @statuses = Milestone::Status.all
    end

    def redirect_path
      polymorphic_path([@namespace, @milestoneable, Milestone.new])
    end

    def milestoneable_path
      redirect_path
    end
end
