require_dependency Rails.root.join("app", "components", "budgets", "investments", "new_component").to_s

class Budgets::Investments::NewComponent < ApplicationComponent
  attr_reader :investment
  delegate :back_link_to, to: :helpers

  def initialize(budget, investment = nil)
    @budget = budget
    @investment = investment
  end

  private

    def budgets_back_link_path
      if params[:projekt_phase_id].present?
        link_to url_to_footer_tab, class: "back" do
          tag.span(class: "icon-angle-left") + t("shared.back")
        end

      elsif params[:origin].present?
        link_to params[:origin], class: "back" do
          tag.span(class: "icon-angle-left") + t("shared.back")
        end

      else
        back_link_to budgets_path

      end
    end

    def base_title
      @budget.projekt_phase&.resource_form_title&.presence ||
        sanitize(t("budgets.investments.form.title"))
    end

    def subtitle
      if @budget.show_money?
        tag.span budget.formatted_heading_price(budget.headings.first)
      end
    end
end
