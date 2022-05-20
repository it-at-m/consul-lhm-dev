class AddShowOnIndexPageToPolls < ActiveRecord::Migration[5.2]
  def change
    add_column :polls, :show_on_index_page, :boolean, default: true
  end
end
