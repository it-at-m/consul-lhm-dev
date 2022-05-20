class AddShowCountOfVotesToProjektQuestions < ActiveRecord::Migration[5.2]
  def change
    add_column :projekt_questions, :show_answers_count, :boolean, default: true
  end
end
