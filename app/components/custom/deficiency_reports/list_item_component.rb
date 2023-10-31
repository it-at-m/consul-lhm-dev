# frozen_string_literal: true

class DeficiencyReports::ListItemComponent < ApplicationComponent
  attr_reader :deficiency_report

  def initialize(deficiency_report:)
    @deficiency_report = deficiency_report
  end

  def component_attributes
    {
      resource: deficiency_report,
      title: deficiency_report.title,
      description: deficiency_report.description,
      tags: deficiency_report.tags.first(3),
      url: helpers.deficiency_report_path(deficiency_report),
      image_url: deficiency_report.image&.variant(:card_thumb),
      image_placeholder_icon_class: "fa-lightbulb",
      subline: subline
    }
  end

  def subline
    link_to deficiency_reports_path(dr_categories: deficiency_report.category.id) do
      tag.i(
        class: "fas fa-#{deficiency_report.category.icon.presence || "circle"}",
        style: "color:#{deficiency_report.category.color};margin-right:0.5rem;"
      ) + deficiency_report.category.name
    end
  end
end
