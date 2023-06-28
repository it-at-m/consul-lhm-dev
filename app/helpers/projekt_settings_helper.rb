module ProjektSettingsHelper
  def projekt_feature?(projekt, feature)
    setting = ProjektSetting.find_by(projekt: projekt, key: "projekt_feature.#{feature}")
    (setting && (setting.value == 'active' || setting.value == 't'  )) ? true : false
  end

  def projekt_option(projekt, option)
    ProjektSetting.find_by(projekt: projekt, key: "projekt_feature.#{option}").value
  end
end
