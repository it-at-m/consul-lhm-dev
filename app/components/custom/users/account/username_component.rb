class Users::Account::UsernameComponent < ApplicationComponent
  def initialize(user:, edit_mode: false, show_form: false)
    @user = user
    @edit_mode = edit_mode
    @show_form = show_form
  end
end
