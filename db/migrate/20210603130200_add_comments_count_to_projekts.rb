class AddCommentsCountToProjekts < ActiveRecord::Migration[5.2]
  def change
    add_column :projekts, :comments_count, :integer, default: 0
    add_column :projekts, :hidden_at, :datetime
    add_column :projekts, :author_id, :integer
  end
end
