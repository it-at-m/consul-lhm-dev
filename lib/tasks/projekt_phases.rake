namespace :projekt_phases do
  desc "Invalidates fragment cache when projekt phase changes it's current status"
  task check_currentness_change: :environment do
    ApplicationLogger.new.info "Checking projekt phases for currentness change"
    ProjektPhase.all.each do |phase|
      if (phase.start_date.present? && phase.start_date == Time.zone.today) ||
          (phase.end_date.present? && phase.end_date == Time.zone.yesterday)
        phase.touch
      end
    end

    Projekt.all.each do |projekt|
      if (projekt.total_duration_start.present? && projekt.total_duration_start == Time.zone.today) ||
          (projekt.total_duration_end.present? && projekt.total_duration_end == Time.zone.yesterday)
        projekt.touch
      end
    end
  end
end
