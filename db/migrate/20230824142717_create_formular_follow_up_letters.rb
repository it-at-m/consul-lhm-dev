class CreateFormularFollowUpLetters < ActiveRecord::Migration[5.2]
  def change
    create_table :formular_follow_up_letters do |t|
      t.references :formular, foreign_key: true
      t.string :subject
      t.string :from
      t.text :body
      t.date :sent_at

      t.timestamps
    end
  end
end
