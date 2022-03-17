class Moderation::ProposalsController < Moderation::BaseController
  include ModerateActions
  include FeatureFlags

  has_filters %w[all unseen seen], only: :index
  has_orders %w[flags created_at], only: :index

  feature_flag :proposals

  before_action :load_resources, only: [:index, :moderate, :show, :update]

  load_and_authorize_resource

  def show
    @proposal = Proposal.find params[:id]
  end

  def update
    @proposal = Proposal.find params[:id]
    if @proposal.update(proposal_params)
      redirect_to moderation_proposal_path(@proposal), notice: t("admin.proposals.update.notice")
    else
      render :show
    end
  end

  private

    def resource_model
      Proposal
    end

    def proposal_params
      params.require(:proposal).permit(:tag_list)
    end
end
