class FormularAnswers::DocumentFieldsComponent < ApplicationComponent
  attr_reader :f, :formular_answer, :formular_field

  def initialize(f:, formular_field:, formular_answer:)
    @f = f
    @formular_field = formular_field
    @formular_answer = formular_answer
  end

  private

    def formular_answer_document
      f.object
    end

    def destroy_link(formular_answer_document)
      if !formular_answer_document.persisted? && formular_answer_document.cached_attachment.present?
        link_to t("documents.form.delete_button"), "#", class: "delete remove-cached-attachment"
      else
        link_to_remove_association t("documents.form.delete_button"), f, class: "delete remove-document"
      end
    end

    def file_field(formular_answer_document)
      klass = formular_answer_document.persisted? || formular_answer_document.cached_attachment.present? ? " hide" : ""
      f.file_field :attachment,
        label_options: { class: "button hollow #{klass}" },
        accept: accepted_content_types_extensions,
        class: "js-document-attachment",
        data: { url: direct_upload_path }
    end

    def direct_upload_path
      formular_answer_attachment_direct_uploads_path(
        "direct_upload[formular_answer_id]": formular_answer.id,
        "direct_upload[formular_field_key]": formular_field.key
      )
    end

    def accepted_content_types_extensions
			Setting.accepted_content_types_for("documents")
    end
end
