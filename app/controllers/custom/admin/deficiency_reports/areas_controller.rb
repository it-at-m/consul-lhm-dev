class Admin::DeficiencyReports::AreasController < Admin::BaseController
  include MapLocationAttributes
  load_and_authorize_resource :area, class: "DeficiencyReport::Area", except: :show

  def index
    @areas = DeficiencyReport::Area.all.order(:id)
  end

  def new
    @area.map_location = MapLocation.new(
      latitude: Setting["map.latitude"],
      longitude: Setting["map.longitude"],
      zoom: Setting["map.zoom"]
    )
  end

  def edit
  end

  def create
    @area = DeficiencyReport::Area.new(area_params)

    if @area.save
      redirect_to admin_deficiency_report_areas_path
    else
      render :new
    end
  end

  def update
    if @area.update(area_params)
      redirect_to admin_deficiency_report_areas_path
    else
      render :edit
    end
  end

  def destroy
    if @area.safe_to_destroy?
      @area.destroy!
      redirect_to admin_deficiency_report_areas_path,
        notice: t("custom.admin.deficiency_reports.areas.destroy.destroyed_successfully")
    else
      redirect_to admin_deficiency_report_areas_path,
        alert: t("custom.admin.deficiency_reports.areas.destroy.cannot_be_destroyed")
    end
  end

  private

    def area_params
      params.require(:deficiency_report_area).permit(:name, map_location_attributes: map_location_attributes)
    end
end
