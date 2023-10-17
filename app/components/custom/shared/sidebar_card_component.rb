# frozen_string_literal: true

class Shared::SidebarCardComponent < ApplicationComponent
  renders_many :additional_sections

  def initialize(title: nil, description: nil, icon_name: "info", class_name: nil, mobile_filter: false)
    @title = title
    @icon_name = icon_name
    @class_name = class_name
    @description = description
    @mobile_filter = mobile_filter
  end

  def class_name
    if @mobile_filter
      "#{@class_name} -mobile-filter"
    else
      @class_name
    end
  end
end
