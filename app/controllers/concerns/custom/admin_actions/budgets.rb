module AdminActions::Budgets
  extend ActiveSupport::Concern

  include Translatable
  include ReportAttributes
  include ImageAttributes
  include FeatureFlags

  included do
    feature_flag :budgets

    has_filters %w[all open finished], only: :index

    before_action :load_budget, except: [:index]
    load_and_authorize_resource
  end

  def index
    @budgets = Budget.send(@current_filter).order(created_at: :desc).page(params[:page])

    if @namespace == :projekt_management
      @projekts = Projekt.with_pm_permission_to("manage", current_user.projekt_manager)
      @budgets = @budgets.joins(:projekt_phase).where(projekt_phases: { projekt_id: @projekts.pluck(:id) })
    end

    render "admin/budgets/index"
  end

  def show
    render "admin/budgets/show"
  end

  def edit
    render "admin/budgets/edit"
  end

  def publish
    @budget.publish!
    redirect_to polymorphic_path([@namespace, @budget]), notice: t("admin.budgets.publish.notice")
  end

  def calculate_winners
    @budget.headings.each { |heading| Budget::Result.new(@budget, heading).delay.calculate_winners }
    redirect_to polymorphic_path([@namespace, @budget, :budget_investments], advanced_filters: ["winners"]),
      notice: I18n.t("admin.budgets.winners.calculated")
  end

  def recalculate_winners
    @budget.headings.each { |heading| Budget::Result.new(@budget, heading).calculate_winners }
    redirect_to polymorphic_path([@namespace, @budget, :budget_investments], advanced_filters: ["winners"]),
      notice: "Ergebnisse erfolgreich berechnet."
  end

  def update
    if @budget.update(budget_params)
      redirect_to polymorphic_path([@namespace, @budget]), notice: t("admin.budgets.update.notice")
    else
      render "admin/budgets/edit"
    end
  end

  def destroy
    if @budget.investments.any?
      redirect_to polymorphic_path([@namespace, @budget]), alert: t("admin.budgets.destroy.unable_notice")
    elsif @budget.poll.present?
      redirect_to polymorphic_path([@namespace, @budget]), alert: t("admin.budgets.destroy.unable_notice_polls")
    else
      @budget.destroy!
      redirect_to polymorphic_path([@namespace, @budget]), notice: t("admin.budgets.destroy.success_notice")
    end
  end

  private

    def budget_params
      params.require(:budget).permit(allowed_params)
    end

    def allowed_params
      descriptions = Budget::Phase::PHASE_KINDS.map { |p| "description_#{p}" }.map(&:to_sym)
      valid_attributes = [:phase,
                          :currency_symbol,
                          :voting_style,
                          :hide_money,
                          :max_number_of_winners,
                          administrator_ids: [],
                          valuator_ids: [],
                          image_attributes: image_attributes
      ] + descriptions

      [*valid_attributes, *report_attributes, translation_params(Budget)]
    end

    def load_budget
      @budget = Budget.find_by_slug_or_id! params[:id]
    end



end
