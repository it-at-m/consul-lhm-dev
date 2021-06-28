require_dependency Rails.root.join("app", "controllers", "admin", "milestones_controller").to_s

class Admin::MilestonesController < Admin::BaseController

  def create
    @milestone = @milestoneable.milestones.new(milestone_params)

    if @milestone.save
      if @milestoneable.class.name == "Projekt"
        redirect_to edit_admin_projekt_path(@milestoneable) + "#tab-projekt-milestones", notice: t("admin.milestones.create.notice")
      else
        redirect_to milestoneable_path, notice: t("admin.milestones.create.notice")
      end
    else
      render :new
    end
  end

  def update
    if @milestone.update(milestone_params)
      if @milestoneable.class.name == "Projekt"
        redirect_to edit_admin_projekt_path(@milestoneable) + "#tab-projekt-milestones", notice: t("admin.milestones.update.notice")
      else
        redirect_to milestoneable_path, notice: t("admin.milestones.update.notice")
      end
    else
      render :edit
    end
  end

  def destroy
    @milestone.destroy!
    if @milestoneable.class.name == "Projekt"
      redirect_to edit_admin_projekt_path(@milestoneable) + "#tab-projekt-milestones", notice: t("admin.milestones.delete.notice")
    else
      redirect_to milestoneable_path, notice: t("admin.milestones.delete.notice")
    end
  end
end
