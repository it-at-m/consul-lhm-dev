require_dependency Rails.root.join("app", "controllers", "management", "proposals_controller").to_s

class Management::ProposalsController < Management::BaseController

  private

    def allowed_params
      attributes = [:video_url, :responsible_name, :tag_list,
                    :geozone_id,
                    :terms_of_service, :terms_data_storage, :terms_data_protection, :terms_general,
                    map_location_attributes: map_location_attributes]

      [*attributes, translation_params(Proposal)]
    end
end
