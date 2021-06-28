require_dependency Rails.root.join("app", "models", "map_location").to_s
class MapLocation < ApplicationRecord
  belongs_to :projekt, touch: true

  def json_data
    {
      investment_id: investment_id,
      proposal_id: proposal_id,
      projekt_id: projekt_id,
      lat: latitude,
      long: longitude,
      color: get_pin_color(proposal_id)
    }
  end

  private

  def get_pin_color(proposal_id)
    if proposal_id.present?
      proposal = Proposal.find_by(id: proposal_id)
      proposal.projekt&.map_location&.pin_color
    end
  end
end
