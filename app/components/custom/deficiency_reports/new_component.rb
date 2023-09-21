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
end
