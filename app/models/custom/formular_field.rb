class FormularField < ApplicationRecord
  KINDS = %w[string email date dropdown].freeze

  CUSTOM_ATTRIBUTES = %i[email_for_confirmation drop_down_options].freeze
  CUSTOM_ATTRIBUTES.each { |attr| attr_accessor attr }

  belongs_to :formular
  delegate :projekt_phase, to: :formular

  before_validation :merge_custom_attributes_to_options
  after_create :set_key, :set_options

  validates :name, presence: true, uniqueness: { scope: :formular_id }
  validates :kind, presence: true, inclusion: { in: KINDS }

  default_scope { order(:follow_up, :given_order) }

  scope :primary, -> { where(follow_up: false) }
  scope :follow_up, -> { where(follow_up: true) }

  def self.order_formular_fields(ordered_array)
    ordered_array.each_with_index do |formular_field_id, order|
      find(formular_field_id).update_column(:given_order, (order + 1))
    end
  end

  def set_custom_attributes
    CUSTOM_ATTRIBUTES.each do |attr|
      send("#{attr}=", options[attr.to_s])
    end
  end

  private

    def merge_custom_attributes_to_options
      CUSTOM_ATTRIBUTES.each do |attr|
        options[attr] = send(attr) if send(attr).present?
      end
    end

    def set_key
      update!(key: "#{name.parameterize.underscore}_#{id}")
    end

    def set_options
      update!(options: send("#{kind}_field_options")) if kind.in?(["string", "email"])
    end

    def string_field_options
      {
        validates: {
          length: { minimum: 1, maximum: 255 }
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
