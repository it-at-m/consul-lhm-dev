class AddCardCategoryToWidgetCards < ActiveRecord::Migration[5.2]
  def change
    add_column :widget_cards, :card_category, :string, default: ""
  end
end
