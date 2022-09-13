class ProjektManager < ApplicationRecord
  belongs_to :user, touch: true
  delegate :name, :email, :name_and_email, to: :user

  has_many :projekt_manager_assignments, dependent: :destroy
  has_many :projekts, through: :projekt_manager_assignments

  validates :user_id, presence: true, uniqueness: true
end
