module SentimentActions
  extend ActiveSupport::Concern
  include Translatable

  included do
    respond_to :js

    before_action :set_projekt_phase, :set_namespace
    before_action :set_sentiment, only: %i[edit update destroy]
  end

  def new
    @sentiment = @projekt_phase.sentiments.new
    authorize!(:new, @sentiment) unless current_user.administrator?

    render "custom/admin/sentiments/new"
  end

  def create
    @sentiment = Sentiment.new(sentiment_params)
    @sentiment.projekt_phase = @projekt_phase
    authorize!(:create, @sentiment) unless current_user.administrator?

    if @sentiment.save
      redirect_to polymorphic_path([@namespace, @projekt_phase], action: :sentiments)
    else
      render :new
    end
  end

  def edit
    authorize!(:edit, @sentiment) unless current_user.administrator?
    render "custom/admin/sentiments/edit"
  end

  def update
    authorize!(:update, @sentiment) unless current_user.administrator?

    if @sentiment.update(sentiment_params)
      redirect_to polymorphic_path([@namespace, @projekt_phase], action: :sentiments)
    else
      render :edit
    end
  end

  def destroy
    authorize!(:destroy, @sentiment) unless current_user.administrator?

    @sentiment.destroy!
    redirect_to polymorphic_path([@namespace, @projekt_phase], action: :sentiments)
  end

  private

    def set_projekt_phase
      @projekt_phase = ProjektPhase.find(params[:projekt_phase_id])
    end

    def set_namespace
      @namespace = params[:controller].split("/").first.to_sym
    end

    def set_sentiment
      @sentiment = Sentiment.find(params[:id])
    end

    def sentiment_params
      params.require(:sentiment).permit(:color, :projekt_id, translation_params(ProjektLabel))
    end
end
