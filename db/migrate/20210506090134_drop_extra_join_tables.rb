class DropExtraJoinTables < ActiveRecord::Migration[5.1]
  def change
    drop_table :projekts_proposals
    drop_table :debates_projekts
    drop_table :polls_projekts
    drop_table :budgets_projekts
  end
end
