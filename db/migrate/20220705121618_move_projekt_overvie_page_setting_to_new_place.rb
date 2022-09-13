class MoveProjektOverviePageSettingToNewPlace < ActiveRecord::Migration[5.2]
  def up
    overview_page_show_old_setting = Setting.find_by(key: 'projekts.overview_page')

    if overview_page_show_old_setting.present?
      new_setting = Setting.find_by(key: 'extended_feature.projekts_overview_page_navigation.show_in_navigation')

      if new_setting.present?
        new_setting.update(value: overview_page_show_old_setting.value)

        overview_page_show_old_setting.delete
      end
    end
  end
end
