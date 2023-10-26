# frozen_string_literal: true

class Comments::UserCommentsComponent < ApplicationComponent
  def initialize(comments:)
    @comments = comments
  end

  # def paginate?
  #   controller_name == "welcome" && action_name == "latest_activity"
  # end
end
