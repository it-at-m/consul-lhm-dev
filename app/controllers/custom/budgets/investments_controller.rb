require_dependency Rails.root.join("app", "controllers", "budgets", "investments_controller").to_s

module Budgets
  class InvestmentsController < ApplicationController

    def new
      if @budget.projekt_phase.permission_problem(current_user)
        redirect_to page_path(@budget.projekt.page.slug,
                              projekt_phase_id: @budget.projekt_phase.id,
                              anchor: "filter-subnav")
      end
    end

    def create
      if investment_params["image_attributes"]["cached_attachment"].blank?
        @investment.image = nil
      end

      @investment.author = current_user
      @investment.heading = @budget.headings.first if @budget.single_heading?

      if @investment.save
        Mailer.budget_investment_created(@investment).deliver_later
        NotificationServices::NewBudgetInvestmentNotifier.call(@investment.id) #custom
        redirect_to budget_investment_path(@budget, @investment),
                    notice: t("flash.actions.create.budget_investment")
      else
        render :new
      end
    end

    def update
      custom_investment_params = investment_params

      if investment_params["image_attributes"]["cached_attachment"].blank? && @investment.image.nil?
        custom_investment_params = investment_params.except("image_attributes")
      end

      if @investment.update(custom_investment_params)
        redirect_to budget_investment_path(@budget, @investment),
                    notice: t("flash.actions.update.budget_investment")
      else
        render "edit"
      end
    end

    def flag
      Flag.flag(current_user, @investment)
      redirect_to @investment
    end

    def unflag
      Flag.unflag(current_user, @investment)
      redirect_to @investment
    end

    private

      def investment_params
        attributes = [:heading_id, :tag_list, :organization_name, :location, :on_behalf_of,
                      :related_sdg_list, :implementation_performer, :implementation_contribution, :user_cost_estimate,
                      :terms_of_service, :terms_data_storage, :terms_data_protection, :terms_general, :resource_terms,
                      image_attributes: image_attributes,
                      documents_attributes: document_attributes,
                      map_location_attributes: map_location_attributes]
        params.require(:budget_investment).permit(attributes, translation_params(Budget::Investment))
      end

  end
end
