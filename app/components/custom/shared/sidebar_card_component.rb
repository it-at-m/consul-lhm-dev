# frozen_string_literal: true

class Shared::SidebarCardComponent < ApplicationComponent
  renders_many :additional_sections

  def initialize(title: nil, description: nil, icon_name: "info", class_name: nil, collapsed_on_mobile: true)
    @title = title
    @icon_name = icon_name
    @class_name = class_name
    @description = description
    @collapsed_on_mobile = collapsed_on_mobile
  end

  def class_name
    if @collapsed_on_mobile
      "#{@class_name} -mobile-filter"
    else
      @class_name
    end
  end
end
