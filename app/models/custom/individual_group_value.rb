class IndividualGroupValue < ApplicationRecord
  belongs_to :individual_group
  has_many :user_individual_group_values, dependent: :destroy
  has_many :users, through: :user_individual_group_values

  validates :name, presence: true

  scope :hard, -> { joins(:individual_group).where(individual_groups: { kind: "hard" }) }
  scope :soft, -> { joins(:individual_group).where(individual_groups: { kind: "soft" }) }
end
