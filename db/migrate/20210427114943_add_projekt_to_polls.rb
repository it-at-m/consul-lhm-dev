class AddProjektToPolls < ActiveRecord::Migration[5.1]
  def change
    add_reference :polls, :projekt, foreign_key: true
  end
end
