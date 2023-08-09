class Sidebar::UserResources::ReportComponent < ApplicationComponent
  attr_reader :resource

  def initialize(resource)
    @resource = resource
    @only_content = true
  end
end
