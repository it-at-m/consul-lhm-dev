class Admin::ProjektPhaseMilestonesController < Admin::MilestonesController
  private

    def milestoneable
      ProjektPhase.find(params[:projekt_phase_id])
    end

    def milestoneable_path
      namespaced_polymorphic_path(namespace, @milestoneable, action: :milestones)
    end

    def namespace
      :admin
    end
end
