class Shared::CollapseComponent < ApplicationComponent
  renders_one :head
  renders_one :body

  def initialize(opened_by_default: false)
    @opened_by_default = opened_by_default
  end
end
