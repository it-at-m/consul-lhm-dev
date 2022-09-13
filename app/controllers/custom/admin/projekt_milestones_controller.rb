class Admin::ProjektMilestonesController < Admin::BaseController
  include ProjektMilestoneActions

  def admin_milestone_form_path
    admin_projekt_milestone_path
  end
end
