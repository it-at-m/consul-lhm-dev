class FormularField < ApplicationRecord
  belongs_to :formular

  FIELD_TYPES = %w[email text_field text_area check_box radio_button select].freeze

  private

    def email_field_options
    end
end
