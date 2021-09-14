require_dependency Rails.root.join("app", "helpers", "images_helper").to_s

module ImagesHelper
 def render_image_attachment(builder, imageable, image)
    klass = image.persisted? || image.cached_attachment.present? ? " hide" : ""
    builder.file_field :attachment,
                       label_options: { class: "button hollow #{klass} js-access-label-to-button focusable", tabindex: "0", role: 'button' },
                       accept: imageable_accepted_content_types_extensions,
                       class: "js-image-attachment",
                       data: {
                         url: image_direct_upload_path(imageable),
                         nested_image: true
                       }
  end

  def render_attachment(builder, document)
    klass = document.persisted? || document.cached_attachment.present? ? " hide" : ""
    builder.file_field :attachment,
                       label_options: { class: "button hollow #{klass} js-access-label-to-button focusable", tabindex: "0", role: 'button' },
                       accept: accepted_content_types_extensions(document.documentable_type.constantize),
                       class: "js-document-attachment",
                       data: {
                         url: document_direct_upload_path(document),
                         nested_document: true
                       }
  end
end

