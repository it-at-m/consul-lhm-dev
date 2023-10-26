module ResourceBelongsToProjekt
  extend ActiveSupport::Concern

  included do
    scope :by_projekt_id, ->(projekt_ids) {
      joins(projekt_phase: :projekt)
        .where(projekts: { id: projekt_ids })
    }
  end
end
