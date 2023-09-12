class FormularAnswers::NestedImageComponent < ApplicationComponent
  attr_reader :f, :formular_field, :block_id

  def initialize(f:, formular_field:, block_id: "nested-image")
    @f = f
    @formular_field = formular_field
    @block_id = block_id # for uniqueness custom
  end

  private

    def formular_answer
      f.object
    end

    def note
      t "images.form.note", accepted_content_types: FormularAnswerImage.humanized_accepted_content_types,
        max_file_size: FormularAnswerImage.max_file_size
    end
end
