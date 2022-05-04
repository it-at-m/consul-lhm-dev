class CopyProjektPhasesSettingsToPhaseRecords < ActiveRecord::Migration[5.2]
  def up
    Rake::Task['projekt_settings:migrate_projekt_phases_active_state_to_record'].invoke
  end
end
