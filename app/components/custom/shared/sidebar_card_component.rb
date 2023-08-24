# frozen_string_literal: true

class Shared::SidebarCardComponent < ApplicationComponent
  renders_many :additional_sections

  def initialize(title: nil, description: nil, icon_name: "info", class_name: nil)
    @title = title
    @icon_name = icon_name
    @class_name = class_name
    @description = description
  end
end
