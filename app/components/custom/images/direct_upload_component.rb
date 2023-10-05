class Images::DirectUploadComponent < ApplicationComponent
  renders_one :placeholder
  renders_one :custom_edit_button

  attr_reader :f, :resource_type, :resource_id, :relation_name
  delegate :current_user, :render_image, to: :helpers

  def initialize(f, imageable:, submit_form: false)
    @f = f
    @imageable = imageable
    @submit_form = submit_form

    @resource_type = @imageable.class.name
    @resource_id = @imageable.id
    @relation_name = "image"
  end

  private

    def attachable
      f.object
    end

    def singular_name
      attachable.model_name.singular
    end

    def plural_name
      attachable.model_name.plural
    end

    def file_name
      attachable.attachment_file_name
    end

    def destroy_link_class
      if !attachable.persisted? && attachable.cached_attachment.present?
        "remove-cached-attachment"
      else
        "remove-#{singular_name}"
      end
    end

    def destroy_link
      if !attachable.persisted? && attachable.cached_attachment.present?
        link_to t("#{plural_name}.form.delete_button"), "#", class: "delete #{destroy_link_class}"
      else
        link_to_remove_association remove_association_text, f, class: "delete #{destroy_link_class}"
      end
    end

    def remove_association_text
      if attachable.new_record?
        t("documents.form.cancel_button")
      else
        t("#{plural_name}.form.delete_button")
      end
    end

    def presetuped_file_field
      # klass = attachable.persisted? || attachable.cached_attachment.present? ? " attached" : ""

      f.file_field(
        :attachment,
        label_options: { class: "direct-image-upload--select-button js-direct-image-upload--select-button" },
        label: false,
        accept: accepted_content_types_extensions,
        class: "js-direct-image-upload--input",
        data: { url: direct_upload_path }
      )
    end

    def direct_upload_path
      direct_uploads_path(
        "direct_upload[resource_type]": resource_type,
        "direct_upload[resource_id]": resource_id,
        "direct_upload[resource_relation]": relation_name
      )
    end

    def accepted_content_types_extensions
      Setting.accepted_content_types_for(plural_name).map do |content_type|
        if content_type == "jpg"
          ".jpg,.jpeg"
        else
          ".#{content_type}"
        end
      end.join(",")
    end

    def preview_area_class
      if attachable.attachment.attached?
        "-preview-set"
      end
    end
end
