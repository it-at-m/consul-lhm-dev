class CreateFormularAnswerDocuments < ActiveRecord::Migration[5.2]
  def change
    create_table :formular_answer_documents do |t|
      t.references :formular_answer, foreign_key: true
      t.string :formular_field_key
      t.string :title, limit: 80
      t.string :attachment_file_name
      t.string :attachment_content_type
      t.bigint :attachment_file_size
      t.datetime :attachment_updated_at

      t.timestamps
    end
  end
end
