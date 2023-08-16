class FormularField < ApplicationRecord
  belongs_to :formular

  FIELD_TYPES = %w[string email text_field text_area check_box radio_button select].freeze

  private

    def string_field_options
      {
        validates: {
          presence: true,
          length: { minimum: 2, maximum: 255 }
        }
      }
    end
end
