class Admin::ProjektPhaseProgressBarsController < Admin::ProgressBarsController
  private

    def progressable
      ProjektPhase.find(params[:projekt_phase_id])
    end

    def progress_bars_index
      namespaced_polymorphic_path(namespace, @progressable.progress_bars.new)
    end

    def namespace
      :admin
    end
end
