# frozen_string_literal: true

class Shared::DropdownMenuComponent < ApplicationComponent
  renders_many :options

  attr_reader :selected_option

  def initialize(name: nil, item_css_class: nil, selected_option: nil)
    @name = name
    @item_css_class = item_css_class
    @selected_option = selected_option
  end
end
