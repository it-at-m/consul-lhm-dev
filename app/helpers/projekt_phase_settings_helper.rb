module ProjektPhaseSettingsHelper
  def projekt_phase_feature?(projekt_phase, feature_key)
    # setting = projekt_phase.feature?(feature_key)
    # (setting.present? && (setting.value == "active" || setting.value == "t"))
    projekt_phase.feature?(feature_key)
  end

  def projekt_phase_option(projekt_phase, option_key)
    # projekt_phase.settings.find_by(key: "option.#{option_key}").value
    projekt_phase.option(option_key)
  end
end
