class AddProjektToBudgets < ActiveRecord::Migration[5.2]
  def change
    add_reference :budgets, :projekt, foreign_key: true
  end
end
