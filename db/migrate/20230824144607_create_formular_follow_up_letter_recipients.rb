class CreateFormularFollowUpLetterRecipients < ActiveRecord::Migration[5.2]
  def change
    create_table :formular_follow_up_letter_recipients do |t|
      t.references :formular_follow_up_letter, foreign_key: true, index: { name: "index_recipients_on_formular_follow_up_letter_id" }
      t.references :formular_answer, foreign_key: true, index: { name: "index_recipients_on_formular_answer_id" }
      t.string :email
      t.string :subscription_token

      t.timestamps
    end
  end
end
