require_dependency Rails.root.join("app", "helpers", "translatable_form_helper").to_s

module TranslatableFormHelper
  def translations_interface_enabled?
    Setting["feature.translation_interface"].present? || backend_translations_enabled? || deficiency_report_answer?
  end

  def deficiency_report_answer?
    controller_name == 'deficiency_reports' && action_name == "show"
  end
end
