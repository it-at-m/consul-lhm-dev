class ProjektManagement::Budgets::InvestmentsController < ProjektManagement::BaseController
  include FeatureFlags
  include ModerateActions

  has_filters %w[all unseen seen], only: :index
  has_orders  %w[flags created_at], only: :index

  feature_flag :budgets

  before_action :load_resources, only: [:index, :moderate]

  load_and_authorize_resource class: "Budget::Investment"

  def index
    super

    respond_to do |format|
      format.html do
        render "moderation/budgets/investments/index"
      end

      format.csv do
        send_data Budget::Investment::Exporter.new(@resources).to_csv,
                  filename: "budget_investments.csv"
      end
    end
  end

  private

    def resource_name
      "budget_investment"
    end

    def resource_model
      Budget::Investment
    end
end
