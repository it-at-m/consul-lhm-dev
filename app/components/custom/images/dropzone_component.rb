class Images::DropzoneComponent < ApplicationComponent
  renders_one :placeholder
  renders_one :custom_edit_button

  attr_reader :f
  delegate :current_user, :render_image, to: :helpers

  def initialize(f, attachment_name:, submit_form: false)
    @f = f
    @attachment_name = attachment_name.to_sym
    @submit_form = submit_form
  end

  private

    def attachable
      f.object
    end

    def presetuped_file_field
      # klass = attachable.persisted? || attachable.cached_attachment.present? ? " attached" : ""

      f.file_field(
        @attachment_name,
        label_options: { class: "dropzone-image-upload--select-button js-dropzone-image-upload--select-button" },
        label: false,
        accept: [".jpg", ".jpeg", ".png"].join(","),
        class: "js-dropzone-image-upload--input"
      )
    end

    def accepted_content_types_extensions
    end

    def preview_area_class
      if attachable.send(@attachment_name).attached?
        "-preview-set"
      end
    end
end
