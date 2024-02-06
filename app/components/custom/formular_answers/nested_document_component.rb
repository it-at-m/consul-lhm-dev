class FormularAnswers::NestedDocumentComponent < ApplicationComponent
  attr_reader :f, :formular_field

  def initialize(f:, formular_field:)
    @f = f
    @formular_field = formular_field
  end

  private

    def formular_answer
      @f.object
    end

    def max_documents_allowed
      3
    end

    def max_file_size
      3
    end

    def note
      t "documents.form.note", max_documents_allowed: max_documents_allowed,
        accepted_content_types: FormularAnswerDocument.humanized_accepted_content_types,
        max_file_size: max_file_size
    end

    def max_documents_allowed?
      formular_answer.formular_answer_documents.count >= max_documents_allowed
    end
end
