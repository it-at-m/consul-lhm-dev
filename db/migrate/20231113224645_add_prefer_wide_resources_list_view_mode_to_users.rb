class AddPreferWideResourcesListViewModeToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :prefer_wide_resources_list_view_mode, :boolean, defaut: false
  end
end
