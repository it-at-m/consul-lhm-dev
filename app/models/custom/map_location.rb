require_dependency Rails.root.join("app", "models", "map_location").to_s

class MapLocation < ApplicationRecord
  belongs_to :projekt, touch: true
  belongs_to :deficiency_report, touch: true
  belongs_to :projekt_phase, touch: true

  before_save :ensure_shape_is_json

  def json_data
    {
      investment_id: investment_id,
      proposal_id: proposal_id,
      projekt_id: projekt_id,
      deficiency_report_id: deficiency_report_id,
      lat: latitude,
      long: longitude,
      alt: altitude,
      color: get_pin_color,
      fa_icon_class: get_fa_icon_class
    }
  end

  def shape_json_data
    return {} if shape == {} || shape == "{}"

    shape.merge({
      investment_id: investment_id,
      proposal_id: proposal_id,
      projekt_id: projekt_id,
      deficiency_report_id: deficiency_report_id,
      color: get_pin_color,
      fa_icon_class: get_fa_icon_class
    })
  end

  private

  def get_pin_color
    set_object

    if @proposal.present? && @proposal.projekt_phase.projekt.overview_page?
      "#009900"

    elsif @proposal.present? && @proposal.sentiment.present?
      @proposal.sentiment.color

    elsif @investment.present?
      @investment.projekt.color

    elsif @deficiency_report.present?
      @deficiency_report.category.color

    elsif @projekt.present?
      "red"

    else
      "#004a83"
    end
  end

  def get_fa_icon_class
    set_object

    if @proposal.present? && @proposal.projekt_phase.projekt.overview_page?
      "user"

    elsif @proposal.present? && @proposal.projekt_labels.any?
      @proposal.projekt_labels.count == 1 ? @proposal.projekt_labels.first.icon : "tags"

    elsif @investment.present? && @investment.projekt.present?
      @investment.projekt.icon

    elsif @deficiency_report.present?
      @deficiency_report.category.icon

    elsif @projekt.present?
      @projekt.icon

    else
      "circle"
    end
  end

  def set_object
    @projekt = Projekt.find_by(id: projekt_id) if projekt_id.present?
    @proposal = Proposal.find_by(id: proposal_id) if proposal_id.present?
    @deficiency_report = DeficiencyReport.find_by(id: deficiency_report_id) if deficiency_report_id.present?
    @investment = Budget::Investment.find_by(id: investment_id) if investment_id.present?
  end

  def ensure_shape_is_json
    self.shape = JSON.parse(shape) if shape.is_a?(String)
  rescue JSON::ParserError
    self.shape = {}
  end
end
