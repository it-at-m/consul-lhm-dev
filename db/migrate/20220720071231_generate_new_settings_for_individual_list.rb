class GenerateNewSettingsForIndividualList < ActiveRecord::Migration[5.2]
  def change
    ProjektSetting.ensure_existence
    Setting.add_new_settings
  end
end
