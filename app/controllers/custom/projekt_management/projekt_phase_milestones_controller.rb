class ProjektManagement::ProjektPhaseMilestonesController < Admin::MilestonesController
  include ProjektMilestoneActions

  before_action :set_namespace

  private

    def set_namespace
      @namespace ||= :projekt_management
    end
end
