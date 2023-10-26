class Sidebar::Filters::GeozoneAffiliationsCardComponent < ApplicationComponent
  def initialize(geozones:, resource_name:, selected_affiliated_geozones:)
    @geozones = geozones
    @resource_name = resource_name
    @selected_affiliated_geozones = selected_affiliated_geozones
  end
end
