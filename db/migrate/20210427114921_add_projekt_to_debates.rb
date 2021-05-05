class AddProjektToDebates < ActiveRecord::Migration[5.1]
  def change
    add_reference :debates, :projekt, foreign_key: true
  end
end
