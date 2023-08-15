class ProjektManager < ApplicationRecord
  belongs_to :user, touch: true
  delegate :name, :email, :name_and_email, to: :user

  has_many :projekt_manager_assignments, dependent: :destroy
  has_many :projekts, through: :projekt_manager_assignments

  validates :user_id, presence: true, uniqueness: true

  def allowed_to?(permission, projekt)
    return false unless projekt.present? && permission.present?
    return false unless projekt.is_a?(Projekt)

    assignment = projekt_manager_assignments.find_by(projekt_id: projekt.id)
    return false if assignment.nil?

    assignment.permissions.include?(permission.to_s)
  end
end
