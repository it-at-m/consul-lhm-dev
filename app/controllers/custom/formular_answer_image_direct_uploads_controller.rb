class FormularAnswerImageDirectUploadsController < ApplicationController
  include DirectUploadsHelper
  include ActionView::Helpers::UrlHelper
  skip_authorization_check only: :create

  helper_method :render_destroy_upload_link

  def create
    @formular_answer_image_direct_upload = FormularAnswerImageDirectUpload.new(direct_upload_params.merge(attachment: params[:attachment]))

    if @formular_answer_image_direct_upload.valid?
      @formular_answer_image_direct_upload.save_attachment
      @formular_answer_image_direct_upload.relation.set_cached_attachment_from_attachment


      render json: { cached_attachment: @formular_answer_image_direct_upload.relation.cached_attachment,
                     filename: @formular_answer_image_direct_upload.relation.attachment_file_name,
                     destroy_link: render_destroy_upload_link(@formular_answer_image_direct_upload),
                     attachment_url: polymorphic_path(@formular_answer_image_direct_upload.relation.attachment) }
    else
      render json: { errors: @formular_answer_image_direct_upload.errors[:attachment].join(", ") },
             status: :unprocessable_entity
    end
  end

  private

    def direct_upload_params
      params.require(:direct_upload)
            .permit(allowed_params)
    end

    def allowed_params
      [
        :formular_answer_id, :formular_field_key,
        :resource_relation,
        :attachment, :cached_attachment, attachment_attributes: []
      ]
    end
end
