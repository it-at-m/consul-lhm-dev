class Admin::BaseController < ApplicationController
  layout "admin"
  before_action :authenticate_user!

  skip_authorization_check if: :current_user_administrator?
  before_action :verify_administrator_or_projekt_manager

  private

    def current_user_administrator?
      current_user&.administrator?
    end

    def verify_administrator_or_projekt_manager
      raise CanCan::AccessDenied unless (current_user&.administrator? || current_user&.projekt_manager?)
    end
end
