class Sidebar::Filters::GeozoneRestrictionsCardComponent < ApplicationComponent
  def initialize(geozones:, restricted_geozones:, selected_geozone_restriction:)
    @geozones = geozones
    @restricted_geozones = restricted_geozones
    @selected_geozone_restriction = selected_geozone_restriction
  end
end
