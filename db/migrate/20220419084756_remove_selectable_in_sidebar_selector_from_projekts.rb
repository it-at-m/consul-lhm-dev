class RemoveSelectableInSidebarSelectorFromProjekts < ActiveRecord::Migration[5.2]
  def change
    remove_column :projekts, :selectable_in_sidebar_selector, :jsonb
  end
end
