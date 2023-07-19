class AddProjektPhaseToPolls < ActiveRecord::Migration[5.2]
  def change
    add_reference :polls, :projekt_phase, foreign_key: true
  end
end
