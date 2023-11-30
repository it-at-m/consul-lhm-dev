require_dependency Rails.root.join("app", "models", "map_location").to_s

class MapLocation < ApplicationRecord
  belongs_to :projekt, touch: true
  belongs_to :deficiency_report, touch: true
  belongs_to :projekt_phase, touch: true
  belongs_to :deficiency_report_area, class_name: "DeficiencyReport::Area",
    foreign_key: :deficiency_report_area_id, touch: true, inverse_of: :map_location

  before_save :ensure_shape_is_json
  # before_save :set_pin_styles

  # def set_pin_styles
  #   self.pin_color = get_pin_color
  #   self.fa_icon_class = get_fa_icon_class
  # end

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

    if shape.is_a?(String)
      Sentry.capture_message("MapJSONBug. Shape: #{shape}")
      self.shape = {}
    end

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
    if proposal.present? && proposal.projekt_phase.projekt.overview_page?
      "#009900"

    elsif proposal.present? && proposal.sentiment.present?
      proposal.sentiment.color

    elsif investment.present?
      investment.projekt.color

    elsif deficiency_report.present?
      deficiency_report.category.color

    elsif projekt.present?
      "red"

    else
      "#004a83"
    end
  end

  def get_fa_icon_class
    if proposal.present? && proposal.projekt_labels.any?
      proposal.projekt_labels.size == 1 ? proposal.projekt_labels.first.icon : "tags"

    elsif investment.present? && investment.projekt.present?
      investment.projekt.icon

    elsif deficiency_report.present?
      deficiency_report.category.icon

    elsif projekt.present?
      projekt.icon

    else
      "circle"
    end
  end

  def ensure_shape_is_json
    self.shape = JSON.parse(shape) if shape.is_a?(String)
  rescue JSON::ParserError
    self.shape = {}
  end
end
