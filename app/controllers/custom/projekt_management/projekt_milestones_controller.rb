class ProjektManagement::ProjektMilestonesController < ProjektManagement::BaseController
  include ProjektMilestoneActions

  def admin_milestone_form_path
    projekt_management_projekt_milestone_path
  end
end
