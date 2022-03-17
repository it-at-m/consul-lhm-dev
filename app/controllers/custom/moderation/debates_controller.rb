class Moderation::DebatesController < Moderation::BaseController
  include ModerateActions
  include FeatureFlags

  has_filters %w[all unseen seen], only: :index
  has_orders %w[flags created_at], only: :index

  feature_flag :debates

  before_action :load_resources, only: [:index, :moderate, :show, :update]

  load_and_authorize_resource

  def show
    @debate = Debate.find params[:id]
  end

  def update
    @debate = Debate.find params[:id]
    if @debate.update(debate_params)
      redirect_to moderation_debate_path(@debate), notice: t("admin.debates.update.notice")
    else
      render :show
    end
  end

  private

    def resource_model
      Debate
    end

    def debate_params
      params.require(:debate).permit(:tag_list)
    end
end
