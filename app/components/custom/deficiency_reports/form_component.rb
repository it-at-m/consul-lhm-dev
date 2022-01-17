class DeficiencyReports::FormComponent < ApplicationComponent
  include TranslatableFormHelper
  include GlobalizeHelper
  attr_reader :deficiency_report
  delegate :current_user, :ck_editor_class, to: :helpers

  def initialize(deficiency_report)
    @deficiency_report = deficiency_report
  end

    def categories
      Tag.category.order(:name)
    end
end
