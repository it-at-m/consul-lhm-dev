class AddShowOnHomePageToPolls < ActiveRecord::Migration[5.2]
  def change
    add_column :polls, :show_on_home_page, :boolean, default: true
  end
end
