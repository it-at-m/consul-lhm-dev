class FormularField < ApplicationRecord
  KINDS = %w[string].freeze

  belongs_to :formular
  after_create :set_options

  validates :name, presence: true, uniqueness: { scope: :formular_id }
  validates :kind, presence: true, inclusion: { in: KINDS }

  # KINDS = %w[string email text_field text_area check_box radio_button select].freeze

  private

    def set_options
      update!(options: send("#{kind}_field_options"))
    end

    def string_field_options
      {
        validates: {
          presence: true,
          length: { minimum: 2, maximum: 255 }
        }
      }
    end
end
