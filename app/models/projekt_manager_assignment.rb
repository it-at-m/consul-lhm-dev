class ProjektManagerAssignment < ApplicationRecord
  belongs_to :projekt
  belongs_to :projekt_manager

  ACCEPTABLE_PERMISSIONS = %w[manage moderate create_on_behalf_of].freeze

  default_scope { order(id: :asc) }
end
