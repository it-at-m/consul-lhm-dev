class AddCommentsCountToProjektPhases < ActiveRecord::Migration[5.2]
  def change
    add_column :projekt_phases, :comments_count, :integer, default: 0
    add_column :projekt_phases, :hidden_at, :datetime
  end
end
