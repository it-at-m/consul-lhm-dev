class Admin::ProjektPhaseMilestonesController < Admin::BaseController
  include ProjektMilestoneActions

  private

    def set_namespace
      @namespace ||= :admin
    end
end
