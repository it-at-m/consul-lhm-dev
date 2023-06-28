class AddProjektPhaseToProjektEvents < ActiveRecord::Migration[5.2]
  def change
    add_reference :projekt_events, :projekt_phase, foreign_key: true
  end
end
