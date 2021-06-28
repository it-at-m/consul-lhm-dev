class Admin::ProjektMilestonesController < Admin::MilestonesController
  private

    def milestoneable
      Projekt.find(params[:projekt_id])
    end
end
