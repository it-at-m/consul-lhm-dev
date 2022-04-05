require_dependency Rails.root.join("app", "components", "budgets", "investments", "new_component").to_s

class Budgets::Investments::NewComponent < ApplicationComponent
  delegate :back_link_to, to: :helpers

  private

  def budgets_back_link_path
    if params[:origin] == 'projekt'
      budget = Budget.find(params[:budget_id])
      projekt = budget.projekt
      page = projekt.page
      budget_phase_id = projekt.budget_phase.id

      link_to "/#{page.slug}?selected_phase_id=#{budget_phase_id}", class: "back" do
        tag.span(class: "icon-angle-left") + t("shared.back")
      end

    else
      back_link_to budgets_path

    end
  end

  def subtitle
    tag.span budget.formatted_heading_price(budget.headings.first)
  end
end
