class FormularAnswerImageDirectUpload
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :formular_field_key,
                :relation, :resource_relation,
                :attachment, :cached_attachment

  validates :attachment, presence: true
  validate :parent_resource_attachment_validations,
    if: -> { attachment.present? && relation.present? }

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end

    if @attachment.present? || @cached_attachment.present?
      @formular_answer = FormularAnswer.find_or_initialize_by(id: attributes[:formular_answer_id])

      if (@attachment.present? || @cached_attachment.present?)
        @relation = @formular_answer.formular_answer_images.send("build", relation_attributtes)
      end
    end
  end

  def save_attachment
    @relation.attachment.blob.save!
  end

  def persisted?
    false
  end

  private

    def parent_resource_attachment_validations
      @relation.valid?

      if @relation.errors.key? :attachment
        errors.add(:attachment, @relation.errors.full_messages_for(:attachment))
      end
    end

    def relation_attributtes
      {
        attachment: @attachment,
        cached_attachment: @cached_attachment,
        formular_field_key: @formular_field_key
      }
    end
end
