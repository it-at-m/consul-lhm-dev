class CreateJoinTableIndividualGroupValueProjektPhase < ActiveRecord::Migration[5.2]
  def change
    create_join_table :individual_group_values, :projekt_phases
  end
end
