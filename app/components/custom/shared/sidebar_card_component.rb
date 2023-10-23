# frozen_string_literal: true

class Shared::SidebarCardComponent < ApplicationComponent
  renders_many :additional_sections

  def initialize(
    title: nil, description: nil, icon_name: "info", class_name:
    nil, opened_on_mobile: false
  )
    @title = title
    @icon_name = icon_name
    @class_name = class_name
    @description = description
    @opened_on_mobile = opened_on_mobile
  end

  def class_name
    base_class = @class_name || ""

    if !@opened_on_mobile
      base_class += " -collapsed-on-mobile"
    end

    base_class
  end
end
