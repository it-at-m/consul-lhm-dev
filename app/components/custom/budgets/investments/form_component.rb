require_dependency Rails.root.join("app", "components", "budgets", "investments", "form_component").to_s

class Budgets::Investments::FormComponent < ApplicationComponent

  private

    def options_for_implementation_select
      Budget::Investment.implementation_performers.map do |ip|
        [ t("activerecord.attributes.budget/investment.implementation_performers.#{ip[0]}"), ip[0]]
      end
    end
end
