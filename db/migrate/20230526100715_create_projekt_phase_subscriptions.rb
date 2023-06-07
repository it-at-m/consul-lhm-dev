class CreateProjektPhaseSubscriptions < ActiveRecord::Migration[5.2]
  def change
    create_table :projekt_phase_subscriptions do |t|
      t.references :projekt_phase, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
