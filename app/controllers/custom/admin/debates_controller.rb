class Admin::DebatesController < Admin::BaseController
  include FeatureFlags
  include CommentableActions
  include HasOrders

  feature_flag :debates

  has_orders %w[created_at]

  before_action :load_debate, except: :index


  def show
  end

  def update
    if @debate.update(debate_params)
      redirect_to admin_debate_path(@debate), notice: t("admin.debates.update.notice")
    else
      render :show
    end
  end

  private
    def load_debate
      @debate = Debate.find(params[:id])
    end

    def resource_model
      Debate
    end

    def debate_params
      params.require(:debate).permit(:tag_list, :projekt_id)
    end
end
