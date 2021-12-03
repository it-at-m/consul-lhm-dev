require_dependency Rails.root.join("app", "models", "map_location").to_s
class MapLocation < ApplicationRecord
  belongs_to :projekt, touch: true
  belongs_to :deficiency_report, touch: true

  def json_data
    {
      investment_id: investment_id,
      proposal_id: proposal_id,
      projekt_id: projekt_id,
      deficiency_report_id: deficiency_report_id,
      lat: latitude,
      long: longitude,
      color: get_pin_color,
      fa_icon_class: get_fa_icon_class
    }
  end

  private

  def get_pin_color
    set_object
    if @proposal.present? && @proposal.projekt.present?
      @proposal.projekt.color
    elsif @deficiency_report.present?
      @deficiency_report.category.color
    elsif @projekt.present?
      @projekt.color
    end
  end

  def get_fa_icon_class
    set_object
    if @proposal.present? && @proposal.projekt.present?
      @proposal.projekt.icon
    elsif @deficiency_report.present?
      @deficiency_report.category.icon
    elsif @projekt.present?
      @projekt.icon
    end
  end

  def set_object
    @projekt = Projekt.find_by(id: projekt_id) if projekt_id.present?
    @proposal = Proposal.find_by(id: proposal_id) if proposal_id.present?
    @deficiency_report = DeficiencyReport.find_by(id: deficiency_report_id) if deficiency_report_id.present?
  end
end
