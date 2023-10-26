# frozen_string_literal: true

class Auth::AuthPageTemplateComponent < ApplicationComponent
  renders_one :form
  renders_one :after_card_container

  def initialize(title: nil, description: nil, legend_text: nil)
    @title = title
    @description = description
    @legend_text = legend_text
  end
end
