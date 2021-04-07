require_dependency Rails.root.join("app", "models", "debate").to_s

class Debate
  include Imageable

  has_and_belongs_to_many :projekts

  validates :projekts, presence: true, if: :require_a_projekt?

  def require_a_projekt?
    Setting["projekts.connected_resources"].present? ? true : false
  end
end
