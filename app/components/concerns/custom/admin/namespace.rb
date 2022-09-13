module Admin::Namespace
  def namespace
    if controller.class.name.starts_with?("Admin::BudgetsWizard")
      :admin_budgets_wizard
    elsif params[:controller].include?('projekt_management')
      :admin
    else
      helpers.namespace.to_sym
    end
  end
end
