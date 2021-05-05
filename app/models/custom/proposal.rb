require_dependency Rails.root.join("app", "models", "proposal").to_s
class Proposal < ApplicationRecord

  belongs_to :projekt, optional: true

  validates :projekt_id, presence: true, if: :require_a_projekt?

  def require_a_projekt?
    Setting["projekts.connected_resources"].present? ? true : false
  end
end
