# frozen_string_literal: true

class Comments::UserCommentsComponent < ApplicationComponent
  def initialize(comments:)
    @comments = comments
  end
end
