class AddInterdependentQuestionsModeToPolls < ActiveRecord::Migration[5.2]
  def change
    add_column :polls, :wizard_mode, :boolean, default: false
  end
end
