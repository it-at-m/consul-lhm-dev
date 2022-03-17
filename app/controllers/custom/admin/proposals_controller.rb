class Admin::ProposalsController < Admin::BaseController
  include HasOrders
  include CommentableActions
  include FeatureFlags
  feature_flag :proposals

  has_orders %w[created_at]

  before_action :load_proposal, except: :index
  before_action :set_projekts_for_selector, only: [:update, :show]

  def index
    super

    respond_to do |format|
      format.html
      format.csv do
        send_data Proposals::CsvExporter.new(@resources.limit(nil)).to_csv,
          filename: "proposals.csv"
      end
    end
  end

  def show
    @affiliated_geozones = (params[:affiliated_geozones] || '').split(',').map(&:to_i)
  end

  def update
    if @proposal.update(proposal_params)
      redirect_to admin_proposal_path(@proposal), notice: t("admin.proposals.update.notice")
    else
      render :show
    end
  end

  def toggle_selection
    @proposal.toggle :selected
    @proposal.save!
  end

  def toggle_image
    @proposal.image.toggle!(:concealed)
    redirect_to admin_proposal_path(@proposal)
  end

  private

    def resource_model
      Proposal
    end

    def load_proposal
      @proposal = Proposal.find(params[:id])
    end

    def load_proposals
      @investments = Budget::Investment.scoped_filter(params, @current_filter).order_filter(params)
      @investments = Kaminari.paginate_array(@investments) if @investments.is_a?(Array)
      @investments = @investments.page(params[:page]) unless request.format.csv?
    end

    def proposal_params
      params.require(:proposal).permit(:selected, :tag_list, :projekt_id, :related_sdg_list )
    end
end
