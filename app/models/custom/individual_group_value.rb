class IndividualGroupValue < ApplicationRecord
  belongs_to :individual_group
  validates :name, presence: true
end
