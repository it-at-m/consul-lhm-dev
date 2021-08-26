class AddShowOpenAnswerAuthorNameToPolls < ActiveRecord::Migration[5.2]
  def change
    add_column :polls, :show_open_answer_author_name, :boolean
  end
end
