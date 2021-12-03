class DeficiencyReport::Officer < ApplicationRecord
  belongs_to :user
  has_many :deficiency_reports, foreign_key: :deficiency_report_officer_id

  def name
    user&.name || I18n.t("shared.author_info.author_deleted")
  end

  def email
    user&.email || I18n.t("shared.author_info.email_deleted")
  end
end
