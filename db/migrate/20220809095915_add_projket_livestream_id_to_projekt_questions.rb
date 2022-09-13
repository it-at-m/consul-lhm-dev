class AddProjketLivestreamIdToProjektQuestions < ActiveRecord::Migration[5.2]
  def change
    add_column :projekt_questions, :projekt_livestream_id, :integer
    add_index :projekt_questions, :projekt_livestream_id
  end
end
