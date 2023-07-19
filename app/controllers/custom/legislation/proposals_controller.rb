require_dependency Rails.root.join("app", "controllers", "legislation", "proposals_controller").to_s

class Legislation::ProposalsController < Legislation::BaseController
  private

    def allowed_params
      [
        :legislation_process_id, :title,
        :summary, :description, :video_url, :tag_list,
        :geozone_id,
        :terms_of_service, :terms_data_storage, :terms_data_protection, :terms_general, :resource_terms,
        image_attributes: image_attributes,
        documents_attributes: [:id, :title, :attachment, :cached_attachment, :user_id]
      ]
    end
end
