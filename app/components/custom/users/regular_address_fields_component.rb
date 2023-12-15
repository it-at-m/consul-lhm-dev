class Users::RegularAddressFieldsComponent < ApplicationComponent
  def initialize(user:, f:)
    @user = user
    @f = f
  end
end
