class AddCategoriesSetting < ActiveRecord::Migration[5.1]
  def change
    Setting.init_tags_setting
  end
end
