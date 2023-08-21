class FormularField < ApplicationRecord
  KINDS = %w[string email date dropdown].freeze

  belongs_to :formular
  after_create :set_options

  validates :name, presence: true, uniqueness: { scope: :formular_id }
  validates :key, presence: true, uniqueness: { scope: :formular_id }
  validates :kind, presence: true, inclusion: { in: KINDS }

  private

    def set_options
      update!(options: send("#{kind}_field_options")) if kind.in?(["string", "email"])
    end

    def string_field_options
      {
        validates: {
          length: { minimum: 2, maximum: 255 }
        }
      }
    end

    def email_field_options
      {
        validates: {
          format: URI::MailTo::EMAIL_REGEXP.to_s
        }
      }
    end
end
