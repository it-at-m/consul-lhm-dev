module ProjektPhaseProgressBarActions
  extend ActiveSupport::Concern
  include Translatable

  included do
    before_action :load_progressable
    before_action :load_progress_bar, only: [:edit, :update, :destroy]
    helper_method :progress_bars_index
  end

  def index
    authorize! :new, ProgressBar unless current_user.administrator?
    render "admin/progress_bars/index"
  end

  def new
    @progress_bar = @progressable.progress_bars.new
    authorize! :new, @progress_bar unless current_user.administrator?

    render "admin/progress_bars/new"
  end

  def create
    @progress_bar = @progressable.progress_bars.new(progress_bar_params)
    authorize! :create, @progress_bar unless current_user.administrator?

    if @progress_bar.save
      redirect_to redirect_path, notice: t("admin.progress_bars.create.notice")
    else
      render "admin/progress_bars/new"
    end
  end

  def edit
    authorize! :edit, @progress_bar unless current_user.administrator?
    render "admin/progress_bars/edit"
  end

  def update
    authorize! :update, @progress_bar unless current_user.administrator?

    if @progress_bar.update(progress_bar_params)
      redirect_to redirect_path, notice: t("admin.progress_bars.update.notice")
    else
      render "admin/progress_bars/edit"
    end
  end

  def destroy
    authorize! :destroy, @progress_bar unless current_user.administrator?
    @progress_bar.destroy!

    redirect_to redirect_path, notice: t("admin.progress_bars.delete.notice")
  end

  private

    def progress_bar_params
      params.require(:progress_bar).permit(
        :kind, :percentage,
        translation_params(ProgressBar)
      )
    end

    def progressable
      ProjektPhase.find(params[:projekt_phase_id])
    end

    def load_progressable
      @progressable = progressable
    end

    def load_progress_bar
      @progress_bar = progressable.progress_bars.find(params[:id])
    end

    def redirect_path
      polymorphic_path([@namespace, @progress_bar.progressable, ProgressBar.new])
    end

    def progress_bars_index
      polymorphic_path([@namespace, @progressable, ProgressBar.new])
    end
end
