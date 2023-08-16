class FormularField < ApplicationRecord
  belongs_to :formular
  after_create :set_options

  # KINDS = %w[string email text_field text_area check_box radio_button select].freeze
  KINDS = %w[string].freeze

  private

    def set_options
      update!(options: send("#{kind}_field_options")) if kind.in? KINDS
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
