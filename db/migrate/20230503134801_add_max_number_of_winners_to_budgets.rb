class AddMaxNumberOfWinnersToBudgets < ActiveRecord::Migration[5.2]
  def change
    add_column :budgets, :max_number_of_winners, :integer, default: 0
  end
end
