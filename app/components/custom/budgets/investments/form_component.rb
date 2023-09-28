require_dependency Rails.root.join("app", "components", "budgets", "investments", "form_component").to_s

class Budgets::Investments::FormComponent < ApplicationComponent
  delegate :projekt_feature?, :projekt_phase_feature?, :render_custom_block, :ck_editor_class, :current_user, to: :helpers

  private

    def options_for_implementation_select
      Budget::Investment.implementation_performers.map do |ip|
        [ t("activerecord.attributes.budget/investment.implementation_performers.#{ip[0]}"), ip[0]]
      end
    end

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
end
