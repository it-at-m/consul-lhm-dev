class CreateFormularAnswers < ActiveRecord::Migration[5.2]
  def change
    create_table :formular_answers do |t|
      t.jsonb :answers, null: false, default: {}
      t.references :formular, foreign_key: true

      t.timestamps
    end
  end
end
