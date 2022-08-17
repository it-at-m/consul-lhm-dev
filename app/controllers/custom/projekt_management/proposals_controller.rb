class ProjektManagement::ProposalsController < ProjektManagement::BaseController
  include ModerateActions
  include FeatureFlags

  has_filters %w[all unseen seen], only: :index
  has_orders %w[flags created_at], only: :index

  feature_flag :proposals

  before_action :load_resources, only: [:index, :moderate]

  load_and_authorize_resource

  def index
    super

    respond_to do |format|
      format.html do
        render "moderation/proposals/index"
      end

      format.csv do
        send_data Proposals::CsvExporter.new(@resources.limit(nil)).to_csv,
          filename: "proposals.csv"
      end
    end
  end

  private

    def resource_model
      Proposal
    end
end
