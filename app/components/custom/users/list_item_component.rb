# frozen_string_literal: true

class Users::ListItemComponent < ApplicationComponent
  attr_reader :user

  def initialize(user:)
    @user = user
  end
end
