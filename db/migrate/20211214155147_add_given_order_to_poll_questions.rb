class AddGivenOrderToPollQuestions < ActiveRecord::Migration[5.2]
  def change
    add_column :poll_questions, :given_order, :integer
  end
end
