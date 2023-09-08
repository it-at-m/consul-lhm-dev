class Sidebar::Filters::GeozoneAffiliationsCardComponent < ApplicationComponent
  def initialize(geozones:, resource_name:)
    @geozones = geozones
    @resource_name = resource_name
  end
end
