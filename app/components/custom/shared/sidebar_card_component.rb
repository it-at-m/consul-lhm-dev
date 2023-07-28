# frozen_string_literal: true

class Shared::SidebarCardComponent < ApplicationComponent
  renders_one :body
  renders_many :additional_sections

  def initialize(title: nil, icon_name: "info")
    @title = title
    @icon_name = icon_name
  end
end
