class DeficiencyReports::NewComponent < ApplicationComponent
  include TranslatableFormHelper
  include GlobalizeHelper
  include Header

  attr_reader :deficiency_report
  delegate :back_link_to, :render_custom_block, :ck_editor_class, :current_user, to: :helpers

  def initialize(deficiency_report)
    @deficiency_report = deficiency_report
  end

  def title
    t("custom.deficiency_reports.new.start_new")
  end

  def areas
    @areas ||= DeficiencyReport::Area.all.order(created_at: :asc)
  end

  def map_coordinates_for_areas
    areas.map do |area|
      [area.id, [area.map_location.latitude, area.map_location.longitude]]
    end.to_h
  end
end
