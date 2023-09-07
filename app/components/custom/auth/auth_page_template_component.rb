# frozen_string_literal: true

class Auth::AuthPageTemplateComponent < ApplicationComponent
  renders_one :form

  def initialize(title: nil, description: nil, legend_text: nil)
    @title = title
    @description = description
    @legend_text = legend_text
  end
end
