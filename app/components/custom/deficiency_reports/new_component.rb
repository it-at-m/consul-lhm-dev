class DeficiencyReports::NewComponent < ApplicationComponent
  include Header
  attr_reader :deficiency_report

  def initialize(deficiency_report)
    @deficiency_report = deficiency_report
  end

  def title
    t("custom.deficiency_reports.new.start_new")
  end
end
