class AddProjektToLegislationProcesses < ActiveRecord::Migration[5.2]
  def change
    add_reference :legislation_processes, :projekt, foreign_key: true
  end
end
