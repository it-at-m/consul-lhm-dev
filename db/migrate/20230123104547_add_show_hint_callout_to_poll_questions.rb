class AddShowHintCalloutToPollQuestions < ActiveRecord::Migration[5.2]
  def change
    add_column :poll_questions, :show_hint_callout, :boolean, default: true
  end
end
