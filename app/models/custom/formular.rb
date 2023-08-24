class Formular < ApplicationRecord
  belongs_to :projekt_phase
  has_many :formular_fields, dependent: :destroy
  has_many :formular_answers, dependent: :destroy

  def requires_login?
    projekt_phase.settings.find_by(key: "feature.general.only_registered_users").enabled?
  end
end
