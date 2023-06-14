class Admin::SentimentsController < Admin::BaseController
  include Translatable
  respond_to :js

  before_action :set_projekt_phase
  load_and_authorize_resource only: %i[edit update destroy]

  def new
    @sentiment = Sentiment.new
    authorize! :create, @sentiment
  end

  def create
    @sentiment = Sentiment.new(sentiment_params)
    @sentiment.projekt_phase = @projekt_phase
    authorize! :create, @sentiment

    if @sentiment.save
      redirect_to sentiments_admin_projekt_phase_path(@projekt_phase)
    else
      render :new
    end
  end

  def edit
    render "custom/admin/sentiments/edit"
  end

  def update
    if @sentiment.update(sentiment_params)
      redirect_to sentiments_admin_projekt_phase_path(@projekt_phase)
    else
      render :edit
    end
  end

  def destroy
    @sentiment.destroy!
    redirect_to sentiments_admin_projekt_phase_path(@projekt_phase),
                notice: t("custom.admin.projekt.label.destroy.success")
  end

  private

    def set_projekt_phase
      @projekt_phase = ProjektPhase.find(params[:projekt_phase_id])
    end

    def sentiment_params
      params.require(:sentiment).permit(:color, :projekt_id, translation_params(ProjektLabel))
    end
end
