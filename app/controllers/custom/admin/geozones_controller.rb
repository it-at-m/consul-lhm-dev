require_dependency Rails.root.join("app", "controllers", "admin", "geozones_controller").to_s

class Admin::GeozonesController < Admin::BaseController
  private

    def allowed_params
      [
        :name, :external_code, :census_code, :html_map_coordinates,
        :postal_codes
      ]
    end
end
