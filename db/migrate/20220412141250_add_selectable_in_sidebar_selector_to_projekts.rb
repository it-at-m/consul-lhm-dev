class AddSelectableInSidebarSelectorToProjekts < ActiveRecord::Migration[5.2]
  def change
    add_column :projekts, :selectable_in_sidebar_selector, :jsonb, default: {}
  end
end
