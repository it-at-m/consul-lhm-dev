class CreateProjektPhaseSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :projekt_phase_settings do |t|
      t.references :projekt_phase, foreign_key: true
      t.string :key
      t.string :value
    end

    add_index :projekt_phase_settings, [:key, :projekt_phase_id], unique: true
  end
end
