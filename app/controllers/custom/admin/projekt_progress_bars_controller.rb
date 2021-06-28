class Admin::ProjektProgressBarsController < Admin::ProgressBarsController
  private

    def progressable
      Projekt.find(params[:projekt_id])
    end
end
