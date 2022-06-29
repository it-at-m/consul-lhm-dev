namespace :projekt_settings do
  desc "Ensure existence of projekt settings"
  task ensure_existence: :environment do
    ApplicationLogger.new.info "Making sure projekts have "
    ProjektSetting.ensure_existence
  end

  desc "Remove obsolete tasks"
  task destroy_obsolete: :environment do
    ApplicationLogger.new.info "Removing obsolete settings"
    ProjektSetting.destroy_obsolete
  end

  desc "Migrate phase active state to Phase model for some records"
  task migrate_projekt_phases_active_state_to_record: :environment do
    use_projekt_phase_setting = -> (projekt, setting_name) {
      ProjektSetting.find_by(projekt: projekt, key: "projekt_feature.phase.#{setting_name}").value.present?
    }

    Projekt.find_each do |projekt|
      puts "Migrate phases active status for Projekt with id: #{projekt.id} "

      projekt.comment_phase.update(
        active: use_projekt_phase_setting.call(projekt, "comment")
      )

      projekt.debate_phase.update(
        active: use_projekt_phase_setting.call(projekt, "debate")
      )

      projekt.proposal_phase.update(
        active: use_projekt_phase_setting.call(projekt, "proposal")
      )

      projekt.milestone_phase.update(
        active: use_projekt_phase_setting.call(projekt, "milestone")
      )
    end
  end
end
