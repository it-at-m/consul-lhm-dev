class AddProjektPhaseToProjektQuestions < ActiveRecord::Migration[5.2]
  def change
    add_reference :projekt_questions, :projekt_phase, foreign_key: true
  end
end
