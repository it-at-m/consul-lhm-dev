class AddOnBehalfOfToBudgetInvestments < ActiveRecord::Migration[5.2]
  def change
    add_column :budget_investments, :on_behalf_of, :string
  end
end
