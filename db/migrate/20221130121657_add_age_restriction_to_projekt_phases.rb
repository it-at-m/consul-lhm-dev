class AddAgeRestrictionToProjektPhases < ActiveRecord::Migration[5.2]
  def change
    add_reference :projekt_phases, :age_restriction, foreign_key: true
  end
end
