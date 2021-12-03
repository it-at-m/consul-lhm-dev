class Admin::DebatesController < Admin::BaseController
  include FeatureFlags
  include CommentableActions
  include HasOrders

  feature_flag :debates

  has_orders %w[created_at]

  before_action :load_debate, except: :index
  before_action :set_projekts_for_selector, only: [:update, :show]


  def show
  end

  def new
    redirect_to debates_path if Projekt.top_level.selectable_in_selector('debates', current_user).empty?

    super
  end

  def update
    if @debate.update(debate_params)
      redirect_to admin_debate_path(@debate), notice: t("admin.debates.update.notice")
    else
      render :show
    end
  end

  def toggle_image
    @debate.image.toggle!(:concealed)
    redirect_to admin_debate_path(@debate)
  end


  private
    def load_debate
      @debate = Debate.find(params[:id])
    end

    def resource_model
      Debate
    end

    def debate_params
      params.require(:debate).permit(:tag_list, :projekt_id, :related_sdg_list)
    end
end
